import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_ride/Screens/SetLocationMapScreen.dart';
import 'package:swift_ride/Screens/TripSelectionScreen.dart';
import 'package:swift_ride/Widgets/theme.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String? initialValue;
  const LocationSelectionScreen({super.key, this.initialValue});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final supabase = Supabase.instance.client;
  final googlePlace = GooglePlace("AIzaSyCMH5gotuF6vrX4z8Ak4JFfDhpyvL43g50");

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final FocusNode toFocusNode = FocusNode();

  List<AutocompletePrediction> predictions = [];
  List<Map<String, dynamic>> locationHistory = [];
  String activeField = 'to';

  String? extractCityFromPlacemark(Placemark place) {
    final cityCandidates = [
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
      place.country,
    ];

    for (final candidate in cityCandidates) {
      if (candidate != null) {
        final c = candidate.toLowerCase();
        if (c.contains('islamabad')) return 'Islamabad';
        if (c.contains('rawalpindi')) return 'Rawalpindi';
      }
    }
    return null;
  }

  void autoCompleteSearch(String value) async {
    try {
      if (value.isNotEmpty) {
        var result = await googlePlace.autocomplete.get(value);

        if (result != null && result.predictions != null) {
          final filtered =
              result.predictions!.where((prediction) {
                final desc = prediction.description?.toLowerCase() ?? '';
                return desc.contains("islamabad") ||
                    desc.contains("rawalpindi");
              }).toList();

          setState(() {
            predictions = filtered;
          });
        } else {
          setState(() {
            predictions = [];
          });
        }
      } else {
        setState(() {
          predictions = [];
        });
      }
    } catch (e) {
      debugPrint("Autocomplete error: $e");
      setState(() {
        predictions = [];
      });
    }
  }

  Future<void> setCurrentLocation(String field) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address =
            '${place.name}, ${place.street}, ${place.locality}, ${place.country}';

        setState(() {
          if (field == 'from') {
            fromController.text = address;
          } else {
            toController.text = address;
          }
        });
      }
    } catch (e) {
      debugPrint("Location error: $e");
      setState(() {
        if (field == 'from') {
          fromController.text = 'Current Location';
        } else {
          toController.text = 'Current Location';
        }
      });
    }
  }

  Future<void> saveLocationToHistory(String address, String type) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('location_history').insert({
        'user_id': user.id,
        'address': address,
        'type': type,
      });
    } catch (e) {
      debugPrint("Save history error: $e");
    }
  }

  Future<void> fetchLocationHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('location_history')
        .select('id, address')
        .eq('user_id', user.id)
        .order('inserted_at', ascending: false)
        .limit(10);

    setState(() {
      locationHistory = List<Map<String, dynamic>>.from(
        response as List<dynamic>,
      );
    });
  }

  void showHistoryModal(BuildContext context) async {
    await fetchLocationHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Recent Destinations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: locationHistory.length,
                    itemBuilder: (context, index) {
                      final item = locationHistory[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.deepPurple,
                        ),
                        title: Text(item['address']),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            toController.text = item['address'];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildPredictionList() {
    return predictions.isEmpty
        ? const SizedBox.shrink()
        : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.deepPurple,
                ),
                title: Text(prediction.description ?? ''),
                onTap: () {
                  final selectedAddress = prediction.description ?? '';
                  setState(() {
                    if (activeField == 'from') {
                      fromController.text = selectedAddress;
                      saveLocationToHistory(selectedAddress, 'from');
                    } else {
                      toController.text = selectedAddress;
                      saveLocationToHistory(selectedAddress, 'to');
                    }
                    predictions = [];
                  });
                },
              ),
            );
          },
        );
  }

  @override
  void initState() {
    super.initState();
    setCurrentLocation('from'); // Set current location for from field initially
    fetchLocationHistory();
    toFocusNode.requestFocus();
    if (widget.initialValue != null) {
      toController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    toFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        ),
        title: const Text(
          'Where are you going?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // From field
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: fromController,
                onChanged: (value) {
                  activeField = 'from';
                  autoCompleteSearch(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.my_location,
                    color: Colors.deepPurple,
                  ),
                  hintText: 'From (Enter location or use GPS)',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.my_location_outlined,
                          color: Colors.deepPurple,
                        ),
                        tooltip: 'Use Current Location',
                        onPressed: () => setCurrentLocation('from'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.deepPurple),
                        tooltip: 'Set location on map',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SetLocationMapScreen(),
                            ),
                          );
                          if (result != null && result['address'] != null) {
                            setState(() {
                              fromController.text = result['address'];
                              saveLocationToHistory(result['address'], 'from');
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.deepPurple),
                        onPressed: () => fromController.clear(),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const Icon(Icons.swap_vert, size: 32, color: Colors.deepPurple),

            // To field
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: toController,
                focusNode: toFocusNode,
                onChanged: (value) {
                  activeField = 'to';
                  autoCompleteSearch(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                  ),
                  hintText: 'To (Enter Destination)',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.my_location_outlined,
                          color: Colors.deepPurple,
                        ),
                        tooltip: 'Use Current Location',
                        onPressed: () => setCurrentLocation('to'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.deepPurple),
                        tooltip: 'Set location on map',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SetLocationMapScreen(),
                            ),
                          );
                          if (result != null && result['address'] != null) {
                            setState(() {
                              toController.text = result['address'];
                              saveLocationToHistory(result['address'], 'to');
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.deepPurple),
                        onPressed: () => toController.clear(),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            buildPredictionList(),

            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text(
                'Recent Destinations',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onTap: () => showHistoryModal(context),
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.search),
              label: const Text("Search Trip"),
              onPressed: () {
                if (fromController.text.isNotEmpty &&
                    toController.text.isNotEmpty) {
                  String getCityFromAddress(String address) {
                    final lower = address.toLowerCase();
                    if (lower.contains('islamabad')) return 'Islamabad';
                    if (lower.contains('rawalpindi')) return 'Rawalpindi';
                    return '';
                  }

                  final fromCity = getCityFromAddress(fromController.text);
                  final toCity = getCityFromAddress(toController.text);

                  if (fromCity.isEmpty || toCity.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter valid locations including Islamabad or Rawalpindi',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              TripSelectionScreen(from: fromCity, to: toCity),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both From and To addresses'),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
