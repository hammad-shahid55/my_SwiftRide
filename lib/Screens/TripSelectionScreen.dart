import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/DirectionsMapScreen.dart';
import 'package:swift_ride/Widgets/theme.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

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

  Future<Map<String, dynamic>?> fetchDistanceDuration(
    String origin,
    String destination,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destination&key=$googleMapsApiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'] != null &&
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          final element = data['rows'][0]['elements'][0];
          if (element['status'] == 'OK') {
            return {
              'distance': element['distance']['text'],
              'duration': element['duration']['text'],
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Distance Matrix API error: $e');
    }
    return null;
  }

  Future<void> fetchTrips() async {
    try {
      setState(() => isLoading = true);
      final today = tz.TZDateTime.now(tz.getLocation('Asia/Karachi'));
      final fromCity = widget.from.trim();
      final toCity = widget.to.trim();

      List<Map<String, dynamic>> response;
      if (fromCity == toCity) {
        // Same-city: include any trips that begin or end in this city (and also same-city trips)
        final sameFrom = await supabase
            .from('trips')
            .select()
            .eq('from_city', fromCity)
            .order('depart_time', ascending: true);
        final sameTo = await supabase
            .from('trips')
            .select()
            .eq('to_city', toCity)
            .order('depart_time', ascending: true);
        response = [
          ...List<Map<String, dynamic>>.from(sameFrom),
          ...List<Map<String, dynamic>>.from(sameTo),
        ];
      } else {
        final tripsFromTo = await supabase
            .from('trips')
            .select()
            .eq('from_city', fromCity)
            .eq('to_city', toCity)
            .order('depart_time', ascending: true);

        final tripsToFrom = await supabase
            .from('trips')
            .select()
            .eq('from_city', toCity)
            .eq('to_city', fromCity)
            .order('depart_time', ascending: true);

        response = [
          ...List<Map<String, dynamic>>.from(tripsFromTo),
          ...List<Map<String, dynamic>>.from(tripsToFrom),
        ];
      }

      if (response.isNotEmpty) {
        Map<String, List<Map<String, dynamic>>> loadedTrips = {};
        for (var i = 0; i < 7; i++) {
          final date = today.add(Duration(days: i));
          final dayName = i == 0 ? "Today" : DateFormat('EEE').format(date);

          final tripsForDay =
              response.where((trip) {
                DateTime departUtc =
                    DateTime.parse(trip['depart_time']).toUtc();
                final departDatePKT = tz.TZDateTime.from(
                  departUtc,
                  tz.getLocation('Asia/Karachi'),
                );
                return departDatePKT.day == date.day &&
                    departDatePKT.month == date.month &&
                    departDatePKT.year == date.year;
              }).toList();

          // No API call needed, values already in trip
          loadedTrips[dayName] = tripsForDay;
        }

        setState(() {
          tripData = loadedTrips;
          isLoading = false;
        });
      } else {
        setState(() {
          tripData = {};
          isLoading = false;
        });
      }
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
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
                      String key = day == weekDays[0] ? "Today" : day;
                      final trips = tripData[key] ?? [];
                      final filteredTrips =
                          key == "Today"
                              ? trips.where((trip) {
                                DateTime departUtc =
                                    DateTime.parse(trip['depart_time']).toUtc();
                                final departTimePKT = tz.TZDateTime.from(
                                  departUtc,
                                  tz.getLocation('Asia/Karachi'),
                                );
                                return departTimePKT.isAfter(nowPKT);
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

                            DateTime departUtc =
                                DateTime.parse(trip["depart_time"]).toUtc();
                            DateTime arriveUtc =
                                DateTime.parse(trip["arrive_time"]).toUtc();

                            final departTimePKT = tz.TZDateTime.from(
                              departUtc,
                              tz.getLocation('Asia/Karachi'),
                            );
                            final arriveTimePKT = tz.TZDateTime.from(
                              arriveUtc,
                              tz.getLocation('Asia/Karachi'),
                            );

                            final totalSeats = trip['total_seats'] ?? 12;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DirectionsMapScreen(
                                          fromAddress: trip['from_city'],
                                          toAddress: trip['to_city'],
                                          trip: trip,
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'hh:mm a',
                                                ).format(departTimePKT),
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
                                                ).format(arriveTimePKT),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox.shrink(),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${trip["from"]} → ${trip["to"]}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.deepPurple,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
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
                                            'Distance: ${trip['distance_text'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            'Duration: ${trip['duration_text'] ?? 'N/A'}',
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
