// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrportal/constants/apiconstants.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = true;
  Map<String, dynamic>? dashboardData;

  bool isClockedIn = false;
  Duration workedDuration = Duration.zero;
  Timer? _timer;

  /// 🔑 GET TOKEN
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("🔑 TOKEN FROM STORAGE => $token");
    return token;
  }

  /// 📊 FETCH DASHBOARD
  Future<void> fetchDashboard() async {
    print("🟡 fetchDashboard() called");

    isLoading = true;
    notifyListeners();

    final token = await _getToken();
    if (token == null) {
      print("❌ Token is null");
      isLoading = false;
      dashboardData = null;
      notifyListeners();
      return;
    }

    final url =
        Uri.parse(Apiconstants.baseUrl + Apiconstants.dashboardEndpoint);

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📥 STATUS => ${response.statusCode}");
      print("📥 BODY => ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        dashboardData = decoded["data"];

        final attendance = dashboardData!["attendance"];
        final checkIn = attendance["check_in"];

        if (checkIn != null) {
          _startFromApiTime(checkIn);
          isClockedIn = true;
        }
      } else {
        dashboardData = null;
      }
    } catch (e) {
      print("🔥 DASHBOARD ERROR => $e");
      dashboardData = null;
    }

    isLoading = false;
    notifyListeners();
  }

  /// ⏱ START TIMER FROM API TIME
  void _startFromApiTime(String checkIn) {
    final now = DateTime.now();
    final parts = checkIn.split(":");

    final checkInTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    workedDuration = now.difference(checkInTime);
    _startTimer();
  }

  /// ▶️ START TIMER
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      workedDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// 🔘 CLOCK IN / OUT
  void toggleClock() {
    if (isClockedIn) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    isClockedIn = !isClockedIn;
    notifyListeners();
  }

  /// ⏳ FORMAT TIME
  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
