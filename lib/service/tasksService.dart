// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider extends ChangeNotifier {

  bool isLoading = false;
  List<dynamic> tasks = [];

  final String url = Apiconstants.baseUrl + Apiconstants.tasksEndpoint;

  // ===============================
  // API + PROVIDER METHOD
  // ===============================
  Future<void> getTasks() async {
    print('➡️ getTasks() START');

    isLoading = true;
    notifyListeners();

    try {
      // 🔑 Get token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔑 TOKEN FROM PREFS: $token');

      if (token == null || token.isEmpty) {
        throw Exception('Token is null or empty');
      }

      // 🌐 API CALL
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 STATUS CODE: ${response.statusCode}');
      print('📦 RAW RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        tasks = decoded['data'];

        print('✅ TASKS COUNT: ${tasks.length}');
      } else {
        throw Exception('API Failed');
      }
    } catch (e) {
      print('❌ ERROR IN getTasks(): $e');
    }

    isLoading = false;
    notifyListeners();

    print('⬅️ getTasks() END');
  }
}
