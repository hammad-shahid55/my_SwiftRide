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

      // For each trip, sum booked seats
      final Map<int, int> seatTotals = {};
      for (final t in fetchedTrips) {
        final int tripId = t['id'] as int;
        final bookings = await supabase
            .from('bookings')
            .select('seats, status, ride_time')
            .eq('trip_id', tripId);
        int total = 0;
        for (final b in bookings) {
          total += (b['seats'] ?? 0) as int;
        }
        seatTotals[tripId] = total;
      }

      setState(() {
        trips = List<Map<String, dynamic>>.from(fetchedTrips);
        tripIdToBookedSeats = seatTotals;
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
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Vans',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vans.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final van = vans[index];
                    return Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Image.asset('assets/van_logo.png', width: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  van['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Seats: ${van['seats']}'),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.deepPurple),
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.length,
                  itemBuilder: (context, i) {
                    final trip = trips[i];
                    final from = trip['from'] ?? trip['from_city'] ?? '';
                    final to = trip['to'] ?? trip['to_city'] ?? '';
                    final depart =
                        DateTime.parse(trip['depart_time']).toLocal();
                    final arrive =
                        DateTime.parse(trip['arrive_time']).toLocal();
                    final timeStr =
                        '${DateFormat('hh:mm a').format(depart)} → ${DateFormat('hh:mm a').format(arrive)}';
                    final totalSeats = (trip['total_seats'] ?? 14) as int;
                    final booked = tripIdToBookedSeats[trip['id']] ?? 0;
                    final status = _statusForTrip(trip);
                    final bool isAssignedToMe =
                        (trip['driver_id'] != null) &&
                        (trip['driver_id'] == currentUserId);
                    final bool isUnassigned = (trip['driver_id'] == null);
                    final int? selectedVanId =
                        (trip['van_id'] is int) ? trip['van_id'] as int : null;

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$from → $to',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        status == 'completed'
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          status == 'completed'
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
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
                                Image.asset('assets/van_logo.png', width: 24),
                                const SizedBox(width: 8),
                                const Text('Van: '),
                                DropdownButton<int>(
                                  value: selectedVanId,
                                  hint: const Text('Select Van'),
                                  items:
                                      vans
                                          .map(
                                            (v) => DropdownMenuItem<int>(
                                              value: v['id'] as int,
                                              child: Text(v['name'] as String),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      _setVanForTrip(trip['id'] as int, val);
                                    }
                                  },
                                ),
                                const Spacer(),
                                if (isUnassigned)
                                  ElevatedButton(
                                    onPressed:
                                        () => _assignSelfToTrip(
                                          trip['id'] as int,
                                        ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
