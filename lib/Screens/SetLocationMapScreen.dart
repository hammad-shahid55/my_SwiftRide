import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';

class SetLocationMapScreen extends StatefulWidget {
  const SetLocationMapScreen({super.key});

  @override
  State<SetLocationMapScreen> createState() => _SetLocationMapScreenState();
}

class _SetLocationMapScreenState extends State<SetLocationMapScreen> {
  GoogleMapController? mapController;
  LatLng? selectedPosition;
  String? selectedAddress;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<AutocompletePrediction> predictions = [];
  final googlePlace = GooglePlace("AIzaSyCMH5gotuF6vrX4z8Ak4JFfDhpyvL43g50");

  Future<void> getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permission is required.'),
      ));
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    onMapTap(currentLatLng);
  }

  void onMapTap(LatLng position) async {
    setState(() {
      selectedPosition = position;
      selectedAddress = 'Loading address...';
      predictions = [];
      searchController.text = '';
    });

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      final address = '${p.name}, ${p.street}, ${p.locality}, ${p.country}';
      setState(() {
        selectedAddress = address;
      });
    } else {
      setState(() {
        selectedAddress = "Unknown address";
      });
    }
  }

  void onSave() {
    if (selectedPosition != null && selectedAddress != null) {
      Navigator.pop(context, {
        'lat': selectedPosition!.latitude,
        'lng': selectedPosition!.longitude,
        'address': selectedAddress!,
      });
    }
  }

  void autoCompleteSearch(String value) async {
    if (value.isEmpty) {
      setState(() {
        predictions = [];
      });
      return;
    }

    try {
      var result = await googlePlace.autocomplete.get(value);
      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      } else {
        setState(() {
          predictions = [];
        });
      }
    } catch (e) {
      debugPrint('Autocomplete error: $e');
      setState(() {
        predictions = [];
      });
    }
  }

  Future<void> selectPrediction(AutocompletePrediction prediction) async {
  final details = await googlePlace.details.get(prediction.placeId ?? '');
if (details != null && details.result != null) {
  final geometry = details.result!.geometry;
  if (geometry != null && geometry.location != null) {
    final location = geometry.location!;
    final lat = location.lat;
    final lng = location.lng;
    if (lat != null && lng != null) {
      final position = LatLng(lat, lng);

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
      onMapTap(position);

      setState(() {
        searchController.text = prediction.description ?? '';
        predictions = [];
        searchFocusNode.unfocus();
      });
    } else {
      // lat or lng is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude or Longitude is missing')),
      );
    }
  } else {
    // geometry or location is null
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Geometry information is missing')),
    );
  }
} else {
  // details or result is null
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to fetch place details')),
  );
}

}


  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set location on map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.6844, 73.0479), // Islamabad
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            onTap: onMapTap,
            myLocationEnabled: false,
            markers: selectedPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: selectedPosition!,
                    ),
                  }
                : {},
          ),

          // Search box
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: autoCompleteSearch,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search location',
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  predictions = [];
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    ),
                  ),
                ),

                if (predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(prediction.description ?? ''),
                          onTap: () => selectPrediction(prediction),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Address preview + Save button
          if (selectedAddress != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedAddress!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onSave,
                        child: const Text('Use This Location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating locate me button (right center)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
