// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, dynamic>> reports = [];

  Future<void> fetchReports() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        print("❌ Token not found");
        reports = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final url =
          Uri.parse(Apiconstants.baseUrl + Apiconstants.reportsEndpoint);

      print("➡️ Reports API URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        reports = List<Map<String, dynamic>>.from(decoded["data"]);
      } else {
        reports = [];
      }
    } catch (e) {
      print("🔥 Reports Error: $e");
      reports = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
