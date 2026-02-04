// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrportal/constants/apiconstants.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {final url = Uri.parse(Apiconstants.baseUrl + Apiconstants.loginEndpoint);
      

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded["status"] == true) {
        final data = decoded["data"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        final rawToken = data["token"].replaceFirst("Bearer ", "");

        await prefs.setString("token", rawToken);

        print("✅ RAW TOKEN SAVED => $rawToken");

        isLoading = false;
        notifyListeners();
        return true;
      }

      errorMessage = decoded["message"] ?? "Login failed";
    } catch (e) {
      errorMessage = "Server error";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
