// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;

  List attendanceList = [];

  /// 🔑 Token (used ONLY inside API calls)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("🔑 TOKEN FROM STORAGE => $token");
    return token;
  }

  // =======================
  // 📡 GET ATTENDANCE API
  // =======================
  Future<void> fetchAttendance() async {
    isLoading = true;
    notifyListeners();

    print("🟡 fetchAttendance() START");

    try {
      final token = await _getToken();
      final url =
          Apiconstants.baseUrl + Apiconstants.attendanceEndpoint;

      print("➡️ GET URL => $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📥 STATUS CODE => ${response.statusCode}");
      print("📥 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        attendanceList = decoded['data'] ?? [];
        print("✅ Attendance Count => ${attendanceList.length}");
      } else {
        print("❌ FETCH FAILED");
      }
    } catch (e) {
      print("🔥 ERROR => $e");
    }

    isLoading = false;
    notifyListeners();
    print("🟢 fetchAttendance() END");
  }

  // =======================
  // 📡 POST LATE REASON API
  // =======================
  Future<bool> submitLateReason({
    required int attendanceId,
    required String reason,
  }) async {
    isSubmitting = true;
    notifyListeners();

    print("🟡 submitLateReason() START");
    print("🆔 Attendance ID => $attendanceId");
    print("📝 Reason => $reason");

    try {
      final token = await _getToken();
      final url =
          Apiconstants.baseUrl + Apiconstants.attendanceReasonEndpoint;

      print("➡️ POST URL => $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "attendance_id": attendanceId,
          "late_reason": reason,
        }),
      );

      print("📥 STATUS CODE => ${response.statusCode}");
      print("📥 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Reason submitted successfully");
        await fetchAttendance(); // refresh list
        return true;
      } else {
        print("❌ SUBMIT FAILED");
        return false;
      }
    } catch (e) {
      print("🔥 ERROR => $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
      print("🟢 submitLateReason() END");
    }
  }
}
