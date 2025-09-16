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

  const DirectionsMapScreen({
    super.key,
    required this.fromAddress,
    required this.toAddress,
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

  bool _isDark = false;
  final String _mapStyle = '';

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

          // Animate camera
          LatLngBounds bounds;
          if (fromLatLng!.latitude > toLatLng!.latitude &&
              fromLatLng!.longitude > toLatLng!.longitude) {
            bounds = LatLngBounds(southwest: toLatLng!, northeast: fromLatLng!);
          } else if (fromLatLng!.longitude > toLatLng!.longitude) {
            bounds = LatLngBounds(
              southwest: LatLng(fromLatLng!.latitude, toLatLng!.longitude),
              northeast: LatLng(toLatLng!.latitude, fromLatLng!.longitude),
            );
          } else if (fromLatLng!.latitude > toLatLng!.latitude) {
            bounds = LatLngBounds(
              southwest: LatLng(toLatLng!.latitude, fromLatLng!.longitude),
              northeast: LatLng(fromLatLng!.latitude, toLatLng!.longitude),
            );
          } else {
            bounds = LatLngBounds(southwest: fromLatLng!, northeast: toLatLng!);
          }

          mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        } else {
          debugPrint('Directions API error: ${response.errorMessage}');
        }
      }
    } catch (e) {
      debugPrint('Error getting route: $e');
    }
  }

  Future<void> _toggleMapStyle() async {
    _isDark = !_isDark;
    final style = await DefaultAssetBundle.of(context).loadString(
      _isDark ? 'assets/map_style_dark.json' : 'assets/map_style_light.json',
    );
    mapController.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Preview')),
      body:
          (fromLatLng == null || toLatLng == null)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
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
                    onMapCreated: (controller) async {
                      mapController = controller;
                      final style = await DefaultAssetBundle.of(
                        context,
                      ).loadString(
                        _isDark
                            ? 'assets/map_style_dark.json'
                            : 'assets/map_style_light.json',
                      );
                      mapController.setMapStyle(style);
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: _toggleMapStyle,
                      child: const Icon(
                        Icons.brightness_6,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child:
                        totalDistance.isNotEmpty
                            ? Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Distance: $totalDistance',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
    );
  }
}
