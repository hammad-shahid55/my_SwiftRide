import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/directions.dart' as gmw;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:swift_ride/Widgets/BookingWidget.dart';

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

  final directions = gmw.GoogleMapsDirections(
    apiKey: 'AIzaSyCMH5gotuF6vrX4z8Ak4JFfDhpyvL43g50',
  );

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
                      child: BookingWidget(
                        totalSeats: trip['total_seats'] ?? 1,
                        pricePerSeat: trip['price'] ?? 0,
                        fromCity: trip['from_city'],
                        toCity: trip['to_city'],
                        trip: trip,
                        onBookingCompleted: () {
                          // Refresh trips after booking
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  if (totalDistance.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Route Distance: $totalDistance",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
