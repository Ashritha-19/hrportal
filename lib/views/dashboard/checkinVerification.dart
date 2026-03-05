// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:hrportal/service/dashboard/dashboardservice.dart';

class CheckInVerificationScreen extends StatefulWidget {
  const CheckInVerificationScreen({super.key});

  @override
  State<CheckInVerificationScreen> createState() =>
      _CheckInVerificationScreenState();
}

class _CheckInVerificationScreenState extends State<CheckInVerificationScreen> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _loading = true;
  Position? _position;
  String _address = "";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    try {
      /// ✅ Check device support
      bool isSupported = await _auth.isDeviceSupported();
      bool canCheck = await _auth.canCheckBiometrics;

      if (!isSupported || !canCheck) {
        throw Exception("Biometric not supported on this device");
      }

      /// ✅ Check if biometrics enrolled
      final availableBiometrics = await _auth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        throw Exception("No biometrics enrolled on this device");
      }

      /// 🔐 Authenticate (local_auth 3.0.0 syntax)
      bool didAuthenticate = await _auth.authenticate(
        localizedReason: "Authenticate to complete Check In",
      );

      if (!didAuthenticate) {
        throw Exception("Authentication failed");
      }

      /// ✅ Check Location Service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location service is disabled");
      }

      /// 📍 Permission Handling
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      /// 📍 Get Current Position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      /// 🌍 Convert LatLng → Address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      /// 🧠 Clean formatted address
      String formattedAddress = [
        place.subLocality, // Area (KPHB, LB Nagar etc.)
        place.locality, // City
        place.administrativeArea, // State
        place.postalCode,
      ].where((e) => e != null && e.isNotEmpty).join(", ");

      setState(() {
        _position = position;
        _address = formattedAddress;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Check In Verification")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorUI()
          : _buildSuccessUI(provider),
    );
  }

  /// ✅ SUCCESS UI
  Widget _buildSuccessUI(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.verified, size: 80, color: Colors.green),
          const SizedBox(height: 20),

          Text(
            "Authentication Successful",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(
                "Lat: ${_position?.latitude}\nLng: ${_position?.longitude}",
              ),
              subtitle: Text(_address),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              print("🟢 Confirm button clicked");

              await provider.toggleClock(
                latitude: _position?.latitude,
                longitude: _position?.longitude,
                address: _address,
              );

              Navigator.pop(context, true);
            },
            child: Text(
              provider.isClockedIn ? "Confirm Check Out" : "Confirm Check In",
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ ERROR UI
  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
