import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/DirectionsMapScreen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class TripSelectionScreen extends StatefulWidget {
  final String from;
  final String to;

  const TripSelectionScreen({super.key, required this.from, required this.to});

  @override
  State<TripSelectionScreen> createState() => _TripSelectionScreenState();
}

class _TripSelectionScreenState extends State<TripSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> weekDays;
  Map<String, List<Map<String, dynamic>>> tripData = {};
  bool isLoading = true;

  final supabase = Supabase.instance.client;

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

    fetchTrips();
  }

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);

    final fromCity = widget.from.trim();
    final toCity = widget.to.trim();

    final today = DateTime.now();
    final next7Days = today.add(Duration(days: 6));

    try {
      // Fetch only next 7 days trips
      final response = await supabase
          .from('trips')
          .select()
          .or('from_city.eq.$fromCity,to_city.eq.$toCity')
          .gte('depart_time', today.toIso8601String())
          .lte('depart_time', next7Days.toIso8601String())
          .order('depart_time', ascending: true);

      Map<String, List<Map<String, dynamic>>> loadedTrips = {};
      for (var i = 0; i < 7; i++) {
        final date = today.add(Duration(days: i));
        final dayName = i == 0 ? "Today" : DateFormat('EEE').format(date);

        final tripsForDay =
            response.where((trip) {
              final depart = DateTime.parse(trip['depart_time']);
              return depart.year == date.year &&
                  depart.month == date.month &&
                  depart.day == date.day;
            }).toList();

        loadedTrips[dayName] = tripsForDay;
      }

      setState(() {
        tripData = loadedTrips;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching trips: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nowPKT = tz.TZDateTime.now(tz.getLocation('Asia/Karachi'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Choose Your Trip",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: weekDays.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : TabBarView(
                controller: _tabController,
                children:
                    weekDays.map((day) {
                      final trips = tripData[day] ?? [];
                      final filteredTrips =
                          day == "Today"
                              ? trips.where((trip) {
                                final departUtc =
                                    DateTime.parse(trip['depart_time']).toUtc();
                                final departPKT = tz.TZDateTime.from(
                                  departUtc,
                                  tz.getLocation('Asia/Karachi'),
                                );
                                return departPKT.isAfter(nowPKT);
                              }).toList()
                              : trips;

                      if (filteredTrips.isEmpty) {
                        return const Center(
                          child: Text(
                            "No trips available",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: Colors.deepPurple,
                        onRefresh: fetchTrips,
                        child: ListView.builder(
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];

                            final departUtc =
                                DateTime.parse(trip['depart_time']).toUtc();
                            final arriveUtc =
                                DateTime.parse(trip['arrive_time']).toUtc();

                            final departPKT = tz.TZDateTime.from(
                              departUtc,
                              tz.getLocation('Asia/Karachi'),
                            );
                            final arrivePKT = tz.TZDateTime.from(
                              arriveUtc,
                              tz.getLocation('Asia/Karachi'),
                            );

                            final totalSeats = trip['total_seats'] ?? 14;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DirectionsMapScreen(
                                          fromAddress: trip['from_city'],
                                          toAddress: trip['to_city'],
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            DateFormat(
                                              'hh:mm a',
                                            ).format(departPKT),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          const Text(
                                            "  →  ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'hh:mm a',
                                            ).format(arrivePKT),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${trip["from_city"]} → ${trip["to_city"]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
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
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Seats: $totalSeats',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            "${trip["price"]} PKR",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Distance: ${trip['distance_text']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            'Duration: ${trip['duration_text']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}
