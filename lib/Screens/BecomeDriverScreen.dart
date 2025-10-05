import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Widgets/theme.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});

  @override
  State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  bool isRefreshing = false;
  Map<String, List<Map<String, dynamic>>> tripData = {};
  Map<int, int> tripIdToBookedSeats = {};
  String? currentUserId;
  bool hasDriverProfile = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Map<int, Map<String, int>> tripIdToBookingStatusCounts = {};
  late TabController _tabController;
  late List<String> weekDays;
  DateTime? lastFetchTime;

  final List<Map<String, dynamic>> vans = List.generate(
    10,
    (i) => {
      'id': i + 1,
      'name': 'Van ${i + 1}',
      'seats': 14,
      'plate': 'LXR-${1000 + i}',
    },
  );

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    final today = tz.TZDateTime.now(tz.getLocation('Asia/Karachi'));
    weekDays = List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return index == 0 ? "Today" : DateFormat('EEE').format(date);
    });
    _tabController = TabController(length: weekDays.length, vsync: this);
    currentUserId = supabase.auth.currentUser?.id;
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    // Check if we need to refresh (data is older than 2 minutes or force refresh)
    final now = DateTime.now();
    if (!forceRefresh && 
        lastFetchTime != null && 
        now.difference(lastFetchTime!).inMinutes < 2 && 
        tripData.isNotEmpty) {
      return; // Use cached data
    }

    setState(() {
      isLoading = true;
      isRefreshing = !isLoading;
    });
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

      // Fetch all trips for the next 7 days in one query
      final today = tz.TZDateTime.now(tz.getLocation('Asia/Karachi'));
      final startOfWeek = tz.TZDateTime(tz.getLocation('Asia/Karachi'), today.year, today.month, today.day);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final String orFilter =
          (currentUserId != null)
              ? 'driver_id.is.null,driver_id.eq.' + currentUserId!
              : 'driver_id.is.null';

      // Single query to fetch all trips for the week
      final allTrips = await supabase
          .from('trips')
          .select()
          .gte('depart_time', startOfWeek.toUtc().toIso8601String())
          .lt('depart_time', endOfWeek.toUtc().toIso8601String())
          .or(orFilter)
          .order('depart_time', ascending: true);

      // Get all trip IDs for batch booking query
      final tripIds = allTrips.map((trip) => trip['id'] as int).toList();
      
      // Batch fetch all bookings for all trips in one query
      final Map<int, int> seatTotals = {};
      final Map<int, Map<String, int>> statusCounts = {};
      
      if (tripIds.isNotEmpty) {
        final allBookings = await supabase
            .from('bookings')
            .select('trip_id, seats, status')
            .inFilter('trip_id', tripIds);

        // Process bookings data
        for (final booking in allBookings) {
          final tripId = booking['trip_id'] as int;
          final seats = (booking['seats'] ?? 0) as int;
          final status = (booking['status'] ?? '').toString();
          
          seatTotals[tripId] = (seatTotals[tripId] ?? 0) + seats;
          
          if (!statusCounts.containsKey(tripId)) {
            statusCounts[tripId] = {'booked': 0, 'completed': 0};
          }
          
          if (status == 'completed') {
            statusCounts[tripId]!['completed'] = (statusCounts[tripId]!['completed'] ?? 0) + 1;
          } else if (status == 'booked') {
            statusCounts[tripId]!['booked'] = (statusCounts[tripId]!['booked'] ?? 0) + 1;
          }
        }
      }

      // Organize trips by day
      final Map<String, List<Map<String, dynamic>>> dailyTrips = {};
      for (int i = 0; i < 7; i++) {
        final date = today.add(Duration(days: i));
        final dayKey = i == 0 ? "Today" : DateFormat('EEE').format(date);
        dailyTrips[dayKey] = [];
      }

      // Categorize trips by day
      for (final trip in allTrips) {
        final departTime = DateTime.parse(trip['depart_time']).toLocal();
        final tripDate = DateTime(departTime.year, departTime.month, departTime.day);
        final todayDate = DateTime(today.year, today.month, today.day);
        final daysDiff = tripDate.difference(todayDate).inDays;
        
        if (daysDiff >= 0 && daysDiff < 7) {
          final dayKey = daysDiff == 0 ? "Today" : DateFormat('EEE').format(tripDate);
          dailyTrips[dayKey]!.add(trip);
        }
      }

      setState(() {
        tripData = dailyTrips;
        tripIdToBookedSeats = seatTotals;
        tripIdToBookingStatusCounts = statusCounts;
        isLoading = false;
        isRefreshing = false;
        lastFetchTime = now;
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

  Widget _buildTripsList(List<Map<String, dynamic>> trips) {
    if (isLoading && trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }
    
    if (trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No trips found for this day'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: trips.length,
      itemBuilder: (context, i) {
        final trip = trips[i];
        final from = trip['from'] ?? trip['from_city'] ?? '';
        final to = trip['to'] ?? trip['to_city'] ?? '';
        final depart = DateTime.parse(trip['depart_time']).toLocal();
        final arrive = DateTime.parse(trip['arrive_time']).toLocal();
        final timeStr = '${DateFormat('hh:mm a').format(depart)} → ${DateFormat('hh:mm a').format(arrive)}';
        final totalSeats = (trip['total_seats'] ?? 14) as int;
        final booked = tripIdToBookedSeats[trip['id']] ?? 0;
        final bool isAssignedToMe = (trip['driver_id'] != null) && (trip['driver_id'] == currentUserId);
        final bool isUnassigned = (trip['driver_id'] == null);
        final int? selectedVanId = (trip['van_id'] is int) ? trip['van_id'] as int : null;
        final Map<String, int> counts = tripIdToBookingStatusCounts[trip['id']] ?? const {'booked': 0, 'completed': 0};

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$from → $to",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          size: 18,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip["type"] ?? "",
                          style: const TextStyle(
                            color: Colors.deepPurple,
                          ),
                        ),
                        if (trip["ac"] == true) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.ac_unit,
                            size: 18,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Transform.scale(
                        scaleX: -1,
                        child: Image.asset(
                          'assets/van_logo.png',
                          height: 44,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(timeStr),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Van: '),
                    DropdownButton<int>(
                      value: selectedVanId,
                      hint: const Text('Select Van'),
                      items: vans.map((v) => DropdownMenuItem<int>(
                        value: v['id'] as int,
                        child: Text(v['name'] as String),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _setVanForTrip(trip['id'] as int, val);
                        }
                      },
                    ),
                    const Spacer(),
                    if (isUnassigned)
                      ElevatedButton(
                        onPressed: () => _assignSelfToTrip(trip['id'] as int),
                        child: const Text('Assign me'),
                      )
                    else if (isAssignedToMe)
                      const Chip(
                        label: Text('Assigned to you'),
                        backgroundColor: Color(0xFFE8F5E9),
                      )
                    else
                      const Chip(
                        label: Text('Assigned'),
                        backgroundColor: Color(0xFFFFF3E0),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSeatBar(totalSeats, booked),
                    ),
                    const SizedBox(width: 10),
                    Text('$booked/$totalSeats booked'),
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
                      label: Text('Booked: ${counts['booked'] ?? 0}'),
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Chip(
                      avatar: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text('Completed: ${counts['completed'] ?? 0}'),
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            icon: isRefreshing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: isRefreshing ? null : () => _loadData(forceRefresh: true),
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
                          onRefresh: () => _loadData(forceRefresh: true),
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
                                    color: Colors.white,
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
                                        padding: const EdgeInsets.all(12),
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
                                              '${van['plate']}',
                                              style: TextStyle(
                                                color:
                                                    Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Seats: ${van['seats']}',
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Available Trips',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      TabBar(
                                        controller: _tabController,
                                        isScrollable: true,
                                        labelColor: Colors.deepPurple,
                                        unselectedLabelColor: Colors.grey,
                                        indicatorColor: Colors.deepPurple,
                                        tabs: weekDays.map((day) => Tab(text: day)).toList(),
                                      ),
                                      SizedBox(
                                        height: 400,
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: weekDays.map((day) {
                                            final trips = tripData[day] ?? [];
                                            return _buildTripsList(trips);
                                          }).toList(),
                                        ),
                                              ),
                                            ],
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        ))),
      ),
    );
  }
}
