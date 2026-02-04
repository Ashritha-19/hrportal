// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AttendanceMapScreen extends StatefulWidget {
  const AttendanceMapScreen({super.key});

  @override
  State<AttendanceMapScreen> createState() => _AttendanceMapScreenState();
}

class _AttendanceMapScreenState extends State<AttendanceMapScreen> {
  // OFFICE LOCATION (can come from API later)
  final double officeLat = 17.448294;
  final double officeLng = 78.391487;
  final double officeRadius = 45; // meters

  LatLng? employeeLocation;
  String employeeAddress = "";
  bool insideOffice = false;
  double distance = 0;

  @override
  void initState() {
    super.initState();
    _getEmployeeLocation();
  }

  Future<void> _getEmployeeLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      employeeLocation = LatLng(position.latitude, position.longitude);

      distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLat,
        officeLng,
      );

      insideOffice = distance <= officeRadius;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      employeeAddress =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (employeeLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            options: MapOptions(
              initialCenter: employeeLocation!,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.hrportal.app',
              ),

              /// GEOFENCE CIRCLE
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(officeLat, officeLng),
                    radius: officeRadius,
                    useRadiusInMeter: true,
                    color: Colors.orange.withOpacity(0.35),
                    borderColor: Colors.orange,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

              /// MARKERS
              MarkerLayer(
                markers: [
                  // OFFICE MARKER
                  Marker(
                    point: LatLng(officeLat, officeLng),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),

                  // EMPLOYEE MARKER
                  Marker(
                    point: employeeLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// TOP CARD
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AUTHORISED LOCATION",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text("eParivartan"),
                    const SizedBox(height: 4),
                    Text(
                      "${distance.toStringAsFixed(0)}m • ${insideOffice ? "Inside perimeter" : "Outside perimeter"}",
                      style: TextStyle(
                        color: insideOffice ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BOTTOM SHEET
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Authorised Locations",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text("eParivartan"),
                  const SizedBox(height: 4),
                  Text(employeeAddress, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),

                  /// CLOCK IN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: insideOffice ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: insideOffice
                            ? Colors.green
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Clock In"),
                    ),
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
