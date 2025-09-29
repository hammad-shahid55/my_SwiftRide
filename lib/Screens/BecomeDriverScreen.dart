import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});

  @override
  State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> trips = [];
  Map<int, int> tripIdToBookedSeats = {};
  String? currentUserId;
  bool hasDriverProfile = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Map<int, Map<String, int>> tripIdToBookingStatusCounts = {};

  final List<Map<String, dynamic>> vans = List.generate(
    10,
    (i) => {'id': i + 1, 'name': 'Van ${i + 1}', 'seats': 14},
  );

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser?.id;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      // Ensure auth state
      currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        setState(() => isLoading = false);
        return;
      }

      // Check if driver profile exists
      final driverRow =
          await supabase
              .from('drivers')
              .select('id, full_name, phone')
              .eq('id', currentUserId as Object)
              .maybeSingle();
      hasDriverProfile = driverRow != null;
      if (!hasDriverProfile) {
        setState(() => isLoading = false);
        return; // Show profile form
      }

      // Fetch upcoming trips (today onwards)
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final String orFilter =
          (currentUserId != null)
              ? 'driver_id.is.null,driver_id.eq.' + currentUserId!
              : 'driver_id.is.null';
      final fetchedTrips = await supabase
          .from('trips')
          .select()
          .gte('depart_time', nowIso)
          .or(orFilter)
          .order('depart_time', ascending: true)
          .limit(30);

      // For each trip, sum booked seats and status counts
      final Map<int, int> seatTotals = {};
      final Map<int, Map<String, int>> statusCounts = {};
      for (final t in fetchedTrips) {
        final int tripId = t['id'] as int;
        final bookings = await supabase
            .from('bookings')
            .select('seats, status, ride_time')
            .eq('trip_id', tripId);
        int total = 0;
        int bookedCount = 0;
        int completedCount = 0;
        for (final b in bookings) {
          total += (b['seats'] ?? 0) as int;
          final s = (b['status'] ?? '').toString();
          if (s == 'completed') completedCount += 1;
          if (s == 'booked') bookedCount += 1;
        }
        seatTotals[tripId] = total;
        statusCounts[tripId] = {
          'booked': bookedCount,
          'completed': completedCount,
        };
      }

      setState(() {
        trips = List<Map<String, dynamic>>.from(fetchedTrips);
        tripIdToBookedSeats = seatTotals;
        tripIdToBookingStatusCounts = statusCounts;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load driver data: $e')));
    }
  }

  Future<void> _assignSelfToTrip(int tripId) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in as a driver.')),
      );
      return;
    }
    try {
      await supabase
          .from('trips')
          .update({'driver_id': currentUserId})
          .eq('id', tripId);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assigned to trip successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign trip: ' + e.toString())),
      );
    }
  }

  Future<void> _setVanForTrip(int tripId, int vanId) async {
    try {
      await supabase.from('trips').update({'van_id': vanId}).eq('id', tripId);
      await _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Van assigned to trip')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign van: ' + e.toString())),
      );
    }
  }

  String _statusForTrip(Map<String, dynamic> trip) {
    final String? rideTime = trip['depart_time'];
    if (rideTime == null) return 'open';
    final dt = DateTime.parse(rideTime).toLocal();
    final now = DateTime.now();
    return now.isAfter(dt) ? 'completed' : 'booked';
  }

  Future<void> _saveDriverProfile() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter full name and phone number')),
      );
      return;
    }
    try {
      await supabase.from('drivers').upsert({
        'id': currentUserId,
        'full_name': name,
        'phone': phone,
      });
      setState(() {
        hasDriverProfile = true;
      });
      await _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Driver profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: ' + e.toString())),
      );
    }
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign in to access Driver Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ).then((_) => _loadData());
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Driver Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: _saveDriverProfile,
                        child: const Text(
                          'Save & Continue',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatBar(int totalSeats, int booked) {
    final int clampedBooked = booked.clamp(0, totalSeats);
    return Row(
      children: List.generate(totalSeats, (index) {
        final bool filled = index < clampedBooked;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: filled ? Colors.redAccent : Colors.greenAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A00FF), Color(0xFFFF3B3B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : (currentUserId == null
                    ? _buildSignInPrompt()
                    : (!hasDriverProfile
                        ? _buildDriverProfileForm()
                        : RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Vans',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 110,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: vans.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final van = vans[index];
                                      return Container(
                                        width: 140,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/van_logo.png',
                                              width: 40,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    van['name'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Seats: ${van['seats']}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Upcoming Trips & Bookings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  )
                                else if (trips.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No trips found'),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: trips.length,
                                    itemBuilder: (context, i) {
                                      final trip = trips[i];
                                      final from =
                                          trip['from'] ??
                                          trip['from_city'] ??
                                          '';
                                      final to =
                                          trip['to'] ?? trip['to_city'] ?? '';
                                      final depart =
                                          DateTime.parse(
                                            trip['depart_time'],
                                          ).toLocal();
                                      final arrive =
                                          DateTime.parse(
                                            trip['arrive_time'],
                                          ).toLocal();
                                      final timeStr =
                                          '${DateFormat('hh:mm a').format(depart)} → ${DateFormat('hh:mm a').format(arrive)}';
                                      final totalSeats =
                                          (trip['total_seats'] ?? 14) as int;
                                      final booked =
                                          tripIdToBookedSeats[trip['id']] ?? 0;
                                      final status = _statusForTrip(trip);
                                      final bool isAssignedToMe =
                                          (trip['driver_id'] != null) &&
                                          (trip['driver_id'] == currentUserId);
                                      final bool isUnassigned =
                                          (trip['driver_id'] == null);
                                      final int? selectedVanId =
                                          (trip['van_id'] is int)
                                              ? trip['van_id'] as int
                                              : null;
                                      final Map<String, int> counts =
                                          tripIdToBookingStatusCounts[trip['id']] ??
                                          const {'booked': 0, 'completed': 0};

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '$from → $to',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          status == 'completed'
                                                              ? Colors
                                                                  .green
                                                                  .shade100
                                                              : Colors
                                                                  .orange
                                                                  .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      status.toUpperCase(),
                                                      style: TextStyle(
                                                        color:
                                                            status ==
                                                                    'completed'
                                                                ? Colors
                                                                    .green
                                                                    .shade700
                                                                : Colors
                                                                    .orange
                                                                    .shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(timeStr),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/van_logo.png',
                                                    width: 24,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('Van: '),
                                                  DropdownButton<int>(
                                                    value: selectedVanId,
                                                    hint: const Text(
                                                      'Select Van',
                                                    ),
                                                    items:
                                                        vans
                                                            .map(
                                                              (
                                                                v,
                                                              ) => DropdownMenuItem<
                                                                int
                                                              >(
                                                                value:
                                                                    v['id']
                                                                        as int,
                                                                child: Text(
                                                                  v['name']
                                                                      as String,
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        _setVanForTrip(
                                                          trip['id'] as int,
                                                          val,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  const Spacer(),
                                                  if (isUnassigned)
                                                    ElevatedButton(
                                                      onPressed:
                                                          () =>
                                                              _assignSelfToTrip(
                                                                trip['id']
                                                                    as int,
                                                              ),
                                                      child: const Text(
                                                        'Assign me',
                                                      ),
                                                    )
                                                  else if (isAssignedToMe)
                                                    const Chip(
                                                      label: Text(
                                                        'Assigned to you',
                                                      ),
                                                      backgroundColor: Color(
                                                        0xFFE8F5E9,
                                                      ),
                                                    )
                                                  else
                                                    const Chip(
                                                      label: Text('Assigned'),
                                                      backgroundColor: Color(
                                                        0xFFFFF3E0,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: _buildSeatBar(
                                                      totalSeats,
                                                      booked,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '$booked/$totalSeats booked',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Chip(
                                                    avatar: const Icon(
                                                      Icons.schedule,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      'Booked: ${counts['booked'] ?? 0}',
                                                    ),
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Chip(
                                                    avatar: const Icon(
                                                      Icons.check_circle,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      'Completed: ${counts['completed'] ?? 0}',
                                                    ),
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ))),
      ),
    );
  }
}
