import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:swift_ride/Screens/LocationSelectionScreen.dart';
import 'package:swift_ride/Screens/SignInScreen.dart';
import 'package:swift_ride/Widgets/app_drawer.dart';

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

  DateTime? lastBackPressTime;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchRecentLocations();
    fetchCompletedRides();
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
        .select('from_city, to_city, seats, total_price, status, created_at')
        .eq('user_id', user.id)
        .eq('status', 'completed')
        .order('created_at', ascending: false)
        .limit(10);

    setState(() {
      completedRides =
          (response as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.deepPurple,
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
                      'All lines',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: toggleHistoryView,
                      child: Text(
                        showAllHistory ? 'HIDE ALL' : 'VIEW ALL',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ Completed Rides Section
                if (completedRides.isNotEmpty)
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
                                "${ride['from_city']} → ${ride['to_city']}",
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
                                  Text(
                                    "Status: ${ride['status']}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
