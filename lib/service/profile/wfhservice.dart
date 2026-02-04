import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WfhProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;

  List<Map<String, dynamic>> wfhList = [];

  static const String _wfhListUrl =
      Apiconstants.baseUrl + Apiconstants.wfhEndpoint;

  static const String _submitWfhUrl =
      Apiconstants.baseUrl + Apiconstants.submitWfhEndpoint;

  // ================= TOKEN =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint("❌ WFH TOKEN NOT FOUND");
      return null;
    }

    return "Bearer $token";
  }

  // ================= GET WFH LIST =================
  Future<void> fetchWfhRequests() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(_wfhListUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
      );

      debugPrint("📥 WFH LIST BODY => ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["status"] == true && decoded["data"] != null) {
          wfhList = List<Map<String, dynamic>>.from(decoded["data"]);
        }
      }
    } catch (e) {
      debugPrint("❌ Fetch WFH Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= SUBMIT WFH =================
  Future<bool> submitWfhRequest({
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        isSubmitting = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse(_submitWfhUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode({
          "from_date": fromDate,
          "to_date": toDate,
          "reason": reason,
        }),
      );

      debugPrint("📤 SUBMIT WFH BODY => ${response.body}");

      final decoded = jsonDecode(response.body);

      if (decoded["status"] == true) {
        fetchWfhRequests(); // refresh list
        isSubmitting = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("❌ Submit WFH Error: $e");
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }
}
