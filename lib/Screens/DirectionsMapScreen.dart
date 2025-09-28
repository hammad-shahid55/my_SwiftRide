import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/directions.dart' as gmw;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class DirectionsMapScreen extends StatefulWidget {
  final String fromAddress;
  final String toAddress;
  final Map<String, dynamic> trip;

  const DirectionsMapScreen({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.trip,
  });

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  late GoogleMapController mapController;
  final Set<Polyline> _polylines = {};
  LatLng? fromLatLng;
  LatLng? toLatLng;
  String totalDistance = "";

  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? dropoffIcon;

  final directions = gmw.GoogleMapsDirections(apiKey: 'YOUR_API_KEY_HERE');

  int bookedSeats = 1;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    _getLatLngsAndRoute(widget.fromAddress, widget.toAddress);
  }

  Future<BitmapDescriptor> _resizeMarker(String assetPath, int width) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? resized = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(resized!.buffer.asUint8List());
  }

  Future<void> _loadCustomIcons() async {
    pickupIcon = await _resizeMarker('assets/pick.png', 80);
    dropoffIcon = await _resizeMarker('assets/drop.png', 80);
  }

  Future<void> _getLatLngsAndRoute(String from, String to) async {
    try {
      if (from.toLowerCase() == "current location") {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        fromLatLng = LatLng(position.latitude, position.longitude);
      } else {
        final fromPlaces = await locationFromAddress(from);
        fromLatLng = LatLng(
          fromPlaces.first.latitude,
          fromPlaces.first.longitude,
        );
      }

      final toPlaces = await locationFromAddress(to);
      toLatLng = LatLng(toPlaces.first.latitude, toPlaces.first.longitude);

      if (fromLatLng != null && toLatLng != null) {
        final response = await directions.directionsWithLocation(
          gmw.Location(lat: fromLatLng!.latitude, lng: fromLatLng!.longitude),
          gmw.Location(lat: toLatLng!.latitude, lng: toLatLng!.longitude),
        );

        if (response.isOkay) {
          final route = response.routes.first;
          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(
            route.overviewPolyline.points,
          );

          final polylineCoords =
              decodedPoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList();

          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.blue,
                width: 5,
                points: polylineCoords,
              ),
            );
            totalDistance = route.legs.first.distance.text ?? "";
          });

          LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(
              fromLatLng!.latitude < toLatLng!.latitude
                  ? fromLatLng!.latitude
                  : toLatLng!.latitude,
              fromLatLng!.longitude < toLatLng!.longitude
                  ? fromLatLng!.longitude
                  : toLatLng!.longitude,
            ),
            northeast: LatLng(
              fromLatLng!.latitude > toLatLng!.latitude
                  ? fromLatLng!.latitude
                  : toLatLng!.latitude,
              fromLatLng!.longitude > toLatLng!.longitude
                  ? fromLatLng!.longitude
                  : toLatLng!.longitude,
            ),
          );

          mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        }
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final totalSeats = trip['total_seats'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          (fromLatLng == null || toLatLng == null)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: fromLatLng!,
                        zoom: 12,
                      ),
                      polylines: _polylines,
                      markers: {
                        Marker(
                          markerId: const MarkerId('from'),
                          position: fromLatLng!,
                          icon:
                              pickupIcon ??
                              BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                          infoWindow: const InfoWindow(title: 'Pickup'),
                        ),
                        Marker(
                          markerId: const MarkerId('to'),
                          position: toLatLng!,
                          icon:
                              dropoffIcon ??
                              BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed,
                              ),
                          infoWindow: const InfoWindow(title: 'Drop-off'),
                        ),
                      },
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${trip['from_city']} → ${trip['to_city']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Price per Seat: ${trip['price']} PKR",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    "Seats Available: $totalSeats",
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                const Text(
                                  "Book Seats: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      bookedSeats > 1
                                          ? () => setState(() => bookedSeats--)
                                          : null,
                                ),
                                Text(
                                  "$bookedSeats",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed:
                                      bookedSeats < totalSeats
                                          ? () => setState(() => bookedSeats++)
                                          : null,
                                ),
                                Text(
                                  "Total: ${bookedSeats * trip['price']} PKR",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            if (totalDistance.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                "Route Distance: $totalDistance",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Booking Confirmed for $bookedSeats seat(s)! Total: ${bookedSeats * trip['price']} PKR",
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Book Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
