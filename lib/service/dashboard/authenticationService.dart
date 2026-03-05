// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceProvider extends ChangeNotifier {
  // ================= VARIABLES =================

  bool isClockedIn = false;
  bool isDayCompleted = false;
  bool isLoading = false;

  Duration workedDuration = Duration.zero;
  Timer? _timer;

  String message = "";

  static const url = Apiconstants.baseUrl + Apiconstants.dashboardEndpoint;
      

  // ================= FETCH DASHBOARD =================

  Future<void> fetchDashboard() async {
    print("🟡 fetchDashboard() called");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    print("🔑 TOKEN FROM STORAGE => $token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("📥 DASHBOARD STATUS => ${response.statusCode}");
    print("📥 DASHBOARD BODY => ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final attendance = data['attendance'];

      String? checkIn = attendance['check_in'];
      String? checkOut = attendance['check_out'];

      print("🕒 checkIn: $checkIn");
      print("🕒 checkOut: $checkOut");

      if (checkIn != null && checkOut == null) {
        print("🟢 User currently CLOCKED IN");
        isClockedIn = true;
        isDayCompleted = false;
        startTimerFromApi(checkIn);
      } else if (checkIn != null && checkOut != null) {
        print("🔴 Day completed");
        isClockedIn = false;
        isDayCompleted = true;
        stopTimer();
      } else {
        print("🟡 Not checked in yet");
        isClockedIn = false;
        isDayCompleted = false;
        stopTimer();
      }

      notifyListeners();
    }
  }

  // ================= TIMER =================

  void startTimerFromApi(String checkInTime) {
    print("⏱ Starting timer from API time");

    final now = DateTime.now();
    final parts = checkInTime.split(":");

    final checkInDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    workedDuration = now.difference(checkInDateTime);

    print("⏱ Initial workedDuration: $workedDuration");

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      workedDuration = workedDuration + const Duration(seconds: 1);
      notifyListeners();
    });

    print("▶️ Timer started");
  }

  void stopTimer() {
    print("⏹ Stopping timer");
    _timer?.cancel();
    workedDuration = Duration.zero;
    notifyListeners();
  }

  // ================= CHECK IN / OUT =================

  Future<void> toggleClock() async {
    print("🟢 Button Clicked");

    if (isDayCompleted) {
      print("🚫 Day already completed");
      message = "You have completed attendance for today";
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final endpoint = isClockedIn
        ? "/attendance/check-out"
        : "/attendance/check-in";

    final url = Apiconstants.baseUrl + endpoint;

    print("📤 Calling API => $url");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("📥 ATTENDANCE STATUS => ${response.statusCode}");
    print("📥 ATTENDANCE BODY => ${response.body}");

    isLoading = false;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        message = data['message'];
        print("✅ $message");

        await fetchDashboard();
      }
    } else if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      message = data['messages']['error'];
      print("❌ $message");
    } else {
      message = "Something went wrong";
      print("❌ Unexpected error");
    }

    notifyListeners();
  }
}