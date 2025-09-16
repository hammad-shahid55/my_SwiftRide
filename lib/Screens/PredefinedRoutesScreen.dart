import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class PredefinedRoutesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stops;
  final Map<String, dynamic>? routeInfo;

  const PredefinedRoutesScreen({
    super.key,
    required this.stops,
    required this.routeInfo,
  });

  String _getTodaySchedule(Map<String, dynamic>? scheduleJson) {
    if (scheduleJson == null) return "Not available";

    final today = DateTime.now().weekday;
    const weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayKey = weekdays[today - 1];

    final times = scheduleJson[todayKey];
    if (times == null || times.isEmpty) return "No trips today";

    return times.join(" & ");
  }

  @override
  Widget build(BuildContext context) {
    final schedule = routeInfo?['schedule'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Info"),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (routeInfo != null) ...[
            Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: const Icon(Icons.route),
                title: Text("Distance: ${routeInfo!['total_distance'] ?? 'Unknown'}"),
                subtitle: Text("Time: ${routeInfo!['estimated_time'] ?? 'Unknown'}"),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Today's Schedule"),
                subtitle: Text(_getTodaySchedule(schedule)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Stops", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
          ...stops.mapIndexed((index, stop) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  index == 0 ? Icons.location_on : Icons.place,
                  color: index == 0 ? Colors.red : Colors.blue,
                ),
                title: Text(stop['stop_name']),
                subtitle: Text('Lat: ${stop['stop_lat']}, Lng: ${stop['stop_lng']}'),
                trailing: Text(
                  index == 0 ? 'Pickup' : (index == stops.length - 1 ? 'Drop-off' : 'Stop'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
