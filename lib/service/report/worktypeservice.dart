import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkTypesProvider extends ChangeNotifier {
  bool isLoading = false;
  List<String> workTypes = [];

  Future<void> fetchWorkTypes() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        debugPrint("Token not found for work types");
        workTypes = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(
          "https://hrportal.eparivartan.com/api/v1/employee/work-types",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded["data"];

        workTypes =
            data.map<String>((e) => e["name"].toString()).toList();
      } else {
        workTypes = [];
      }
    } catch (e) {
      debugPrint("Work Types API Error: $e");
      workTypes = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
