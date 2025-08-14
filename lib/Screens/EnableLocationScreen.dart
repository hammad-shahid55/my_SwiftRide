import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swift_ride/Screens/WelcomeScreen.dart';
import 'package:swift_ride/Widgets/custom_button.dart';

class EnableLocationScreen extends StatefulWidget {
  const EnableLocationScreen({super.key});

  @override
  State<EnableLocationScreen> createState() => _EnableLocationScreenState();
}

class _EnableLocationScreenState extends State<EnableLocationScreen> {
  GoogleMapController? _mapController;
  LatLng _mapCenter = const LatLng(37.4219999, -122.0840575);
  bool _showBox = true; // 👈 flag to show/hide the box

  Future<void> _enableLocation() async {
    setState(() {
      _showBox = false; // hide the box immediately
    });

    while (true) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        await Future.delayed(const Duration(seconds: 2));
        continue; // try again
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          continue; // try again
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return; // cannot proceed
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng userPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _mapCenter = userPosition;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: userPosition, zoom: 17),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }

      break; // done
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _mapCenter,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          if (_showBox)
            Positioned(
              left: 24,
              right: 24,
              bottom: 60,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.deepPurple,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enable Your Location',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enable location to help us find rides near you',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Enable Location',
                      onPressed: _enableLocation,
                      isSecondary: false, 
                      textColor: Colors.white, 
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
