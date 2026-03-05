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
  bool isDayCompleted = false;

  Duration workedDuration = Duration.zero;
  Timer? _timer;

  String? message;

  // ================= TOKEN =================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("🔑 TOKEN FROM STORAGE => $token");
    return token;
  }

  void clearMessage() {
    message = null;
  }

  // ================= FETCH DASHBOARD =================

  Future<void> fetchDashboard() async {

    print("🟡 fetchDashboard() called");

    isLoading = true;
    notifyListeners();

    final token = await _getToken();
    if (token == null) {
      print("❌ Token null");
      isLoading = false;
      dashboardData = null;
      notifyListeners();
      return;
    }

    final url = Uri.parse(
      "${Apiconstants.baseUrl}${Apiconstants.dashboardEndpoint}",
    );

    try {

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📥 DASHBOARD STATUS => ${response.statusCode}");
      print("📥 DASHBOARD BODY => ${response.body}");

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);
        dashboardData = decoded["data"];

        final attendance = dashboardData!["attendance"];
        final checkIn = attendance["check_in"];
        final checkOut = attendance["check_out"];

        print("🕒 checkIn: $checkIn");
        print("🕒 checkOut: $checkOut");

        // ================= CLOCKED IN =================
        if (checkIn != null && checkOut == null) {

          print("🟢 User currently CLOCKED IN");

          isClockedIn = true;
          isDayCompleted = false;

          _startFromApiTime(checkIn);
        }

        // ================= DAY COMPLETED =================
        else if (checkIn != null && checkOut != null) {

          print("🔴 Day completed");

          isClockedIn = false;
          isDayCompleted = true;

          _timer?.cancel();

          final now = DateTime.now();

          final checkInParts = checkIn.split(":");
          final checkOutParts = checkOut.split(":");

          final checkInTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(checkInParts[0]),
            int.parse(checkInParts[1]),
            int.parse(checkInParts[2]),
          );

          final checkOutTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(checkOutParts[0]),
            int.parse(checkOutParts[1]),
            int.parse(checkOutParts[2]),
          );

          workedDuration = checkOutTime.difference(checkInTime);

          print("🕒 Final Worked Duration: $workedDuration");
        }

        // ================= NOT CHECKED IN =================
        else {

          print("🟡 Not checked in yet");

          isClockedIn = false;
          isDayCompleted = false;

          _timer?.cancel();
          workedDuration = Duration.zero;
        }

      } else {

        print("❌ Dashboard fetch failed");
        dashboardData = null;
      }

    } catch (e) {
      print("🔥 DASHBOARD ERROR => $e");
      dashboardData = null;
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= TIMER FROM API =================

  void _startFromApiTime(String checkIn) {

    print("⏱ Starting timer from API time");

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

    print("⏱ Initial workedDuration: $workedDuration");

    _startTimer();
  }

  void _startTimer() {

    print("▶️ Timer started");

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      workedDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  // ================= CHECK IN / CHECK OUT =================

  Future<void> toggleClock({
    double? latitude,
    double? longitude,
    String? address,
  }) async {

    print("🟢 Confirm button clicked");

    if (isDayCompleted) {
      message = "You have already completed attendance for today";
      notifyListeners();
      return;
    }

    final token = await _getToken();
    if (token == null) {
      print("❌ No token");
      return;
    }

    final endpoint = isClockedIn
        ? "attendance/check-out"
        : "attendance/check-in";

    final url = Uri.parse("${Apiconstants.baseUrl}$endpoint");

    print("📤 Calling API => $url");

    try {

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "address": address,
        }),
      );

      print("📥 ATTENDANCE STATUS => ${response.statusCode}");
      print("📥 ATTENDANCE BODY => ${response.body}");

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);

        if (decoded["status"] == true) {

          message = decoded["message"];
          print("✅ $message");

          if (!isClockedIn) {

            print("🟢 CHECK IN SUCCESS");

            isClockedIn = true;
            isDayCompleted = false;

            workedDuration = Duration.zero;
            _startTimer();

          } else {

            print("🔴 CHECK OUT SUCCESS");

            isClockedIn = false;
            isDayCompleted = true;

            _timer?.cancel();

            print("🕒 Final worked time kept: $workedDuration");
          }

          notifyListeners();

          await fetchDashboard();      
        }

      } else if (response.statusCode == 400) {

        final decoded = jsonDecode(response.body);
        message = decoded["messages"]["error"];
        print("❌ $message");
        notifyListeners();

      } else {

        message = "Something went wrong";
        notifyListeners();
      }

    } catch (e) {
      print("🔥 Attendance API Error => $e");
    }
  }

  // ================= FORMAT =================

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