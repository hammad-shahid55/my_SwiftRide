import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/LocationSelectionScreen.dart';
import 'package:swift_ride/Screens/SettingsScreen.dart';
import 'package:swift_ride/Screens/WalletScreen.dart';

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
  bool showAllHistory = false;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchRecentLocations();
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
      userName = 'Guest';
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

    await fetchRecentLocations();
  }

  Future<void> _navigateWithDrawerReopen(Widget screen) async {
    Navigator.pop(context); // Close drawer first
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _scaffoldKey.currentState?.openDrawer(); // Reopen drawer on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Hey, $userName',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Color.fromARGB(255, 156, 123, 214)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 106, 63, 207),
                ),
                accountName: Text(
                  'Hello, $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: const Text(
                  "Enjoy your ride...!",
                  style: TextStyle(color: Colors.white),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _navigateWithDrawerReopen(const SettingsScreen()),
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
                title: const Text(
                  'Wallet',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _navigateWithDrawerReopen(const WalletScreen()),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
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
                        avatar: const Icon(Icons.history),
                        label: GestureDetector(
                          onTap:
                              () => navigateToLocationSelection(
                                prefill: location['address'],
                              ),
                          child: Text(location['address']),
                        ),
                        deleteIcon: const Icon(Icons.close),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            const Expanded(child: Center(child: Text('No lines available'))),
          ],
        ),
      ),
    );
  }
}
