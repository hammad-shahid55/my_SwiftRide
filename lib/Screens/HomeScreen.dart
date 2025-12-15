import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:swift_ride/Screens/LocationSelectionScreen.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';
import 'package:swift_ride/Widgets/app_drawer.dart';
import 'package:swift_ride/Widgets/theme.dart';
import 'package:swift_ride/Services/AutoCompletionService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = '...';
  List<Map<String, dynamic>> recentLocations = [];
  List<Map<String, dynamic>> completedRides = [];
  bool showAllHistory = false;
  bool showCompletedCards = true;

  DateTime? lastBackPressTime;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchRecentLocations();
    fetchCompletedRides();
    _checkAutoCompletion();
  }

  /// Check for rides that should be auto-completed
  Future<void> _checkAutoCompletion() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Check user's rides for auto-completion
      await AutoCompletionService.checkUserRidesForCompletion(user.id);
    } catch (e) {
      print('Error checking auto-completion: $e');
    }
  }

  Future<void> fetchUserName() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('profiles')
              .select('name')
              .eq('id', user.id)
              .order('updated_at', ascending: false)
              .limit(1)
              .single();

      setState(() {
        final name = response['name']?.trim();
        userName =
            (name != null && name.isNotEmpty)
                ? name
                : user.email?.split('@').first ?? 'User';
      });
    } else {
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<void> fetchRecentLocations() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('location_history')
        .select('id, address, inserted_at')
        .eq('user_id', user.id)
        .order('inserted_at', ascending: false)
        .limit(showAllHistory ? 50 : 3);

    setState(() {
      recentLocations =
          (response as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
    });
  }

  Future<void> fetchCompletedRides() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('bookings')
        .select('id, trip_id, seats, total_price, status, ride_time, created_at')
        .eq('user_id', user.id)
        .order('ride_time', ascending: false);

    final bookings = (response as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Enrich with trip addresses
    final tripIds = bookings
        .map((b) => b['trip_id'])
        .where((id) => id != null)
        .toSet()
        .toList();
    Map<dynamic, Map<String, dynamic>> tripIdToTrip = {};
    if (tripIds.isNotEmpty) {
      final trips = await supabase
          .from('trips')
          .select('id, from, to')
          .filter('id', 'in', '(${tripIds.join(',')})');
      for (final t in (trips as List)) {
        final m = t as Map<String, dynamic>;
        tripIdToTrip[m['id']] = m;
      }
    }

    final now = DateTime.now();
    final completedOnly = bookings.where((b) {
      final status = (b['status'] as String?) ?? 'booked';
      final rt = b['ride_time'] as String?;
      DateTime? rideTime;
      if (rt != null && rt.isNotEmpty) {
        try {
          rideTime = DateTime.parse(rt);
        } catch (_) {}
      }
      return status == 'completed' || (rideTime != null && rideTime.isBefore(now));
    }).toList();

    final enriched = completedOnly.map((b) {
      final trip = tripIdToTrip[b['trip_id']];
      return {
        ...b,
        'from_address': trip != null ? trip['from'] : null,
        'to_address': trip != null ? trip['to'] : null,
      };
    }).toList();

    // Show only the 5 most recent past rides on the home screen
    final limitedEnriched =
        enriched.length > 5 ? enriched.take(5).toList() : enriched;

    setState(() {
      completedRides = limitedEnriched;
    });
  }

  Future<void> deleteLocation(String id) async {
    await supabase.from('location_history').delete().eq('id', id);
    await fetchRecentLocations();
  }

  Future<void> toggleHistoryView() async {
    setState(() {
      showAllHistory = !showAllHistory;
    });
    await fetchRecentLocations();
  }

  void toggleCompletedView() {
    setState(() {
      showCompletedCards = !showCompletedCards;
    });
  }

  void navigateToLocationSelection({String? prefill}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationSelectionScreen(initialValue: prefill),
      ),
    );

    if (result != null && result is String && result.trim().isNotEmpty) {
      await saveLocationToHistory(result);
      await fetchRecentLocations();
    }
  }

  Future<void> saveLocationToHistory(String address) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existing = await supabase
        .from('location_history')
        .select('id')
        .eq('user_id', user.id)
        .eq('address', address)
        .limit(1);

    if (existing.isEmpty) {
      await supabase.from('location_history').insert({
        'user_id': user.id,
        'address': address,
        'inserted_at': DateTime.now().toIso8601String(),
      });
    } else {
      final id = existing.first['id'];
      await supabase
          .from('location_history')
          .update({'inserted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    }
  }

  Future<void> _navigateWithDrawerReopen(Widget screen) async {
    Navigator.pop(context);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to exit"),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            automaticallyImplyLeading: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
            ),
            title: Text(
              'Hey, $userName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        drawer: AppDrawer(
          userName: userName,
          onLogout: _logout,
          onNavigate: _navigateWithDrawerReopen,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchUserName();
            await fetchRecentLocations();
            await fetchCompletedRides();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => navigateToLocationSelection(),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Where are you going?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (recentLocations.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children:
                        recentLocations.map((location) {
                          return Chip(
                            avatar: const Icon(
                              Icons.history,
                              color: Colors.deepPurple,
                            ),
                            label: GestureDetector(
                              onTap:
                                  () => navigateToLocationSelection(
                                    prefill: location['address'],
                                  ),
                              child: Text(location['address']),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.deepPurple,
                            ),
                            onDeleted: () => deleteLocation(location['id']),
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Past ride history',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: toggleCompletedView,
                      child: Text(
                        showCompletedCards ? 'HIDE' : 'VIEW',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (showCompletedCards && completedRides.isNotEmpty)
                  Column(
                    children:
                        completedRides.map((ride) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(
                                Icons.directions_bus,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                "${ride['from_address'] ?? 'From'} → ${ride['to_address'] ?? 'To'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Seats: ${ride['seats']}"),
                                  Text("Total: ${ride['total_price']} PKR"),
                                  const Text(
                                    "Status: completed",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final fromAddr = ride['from_address'] as String?;
                                final toAddr = ride['to_address'] as String?;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LocationSelectionScreen(
                                      initialFrom: fromAddr,
                                      initialTo: toAddr,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  )
                else
                  const SizedBox(
                    height: 100,
                    child: Center(child: Text("No completed rides available")),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
