// ignore_for_file: use_build_context_synchronously

import 'package:hrportal/views/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
// import your LoginScreen

Future<void> logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // ❌ Remove token
  await prefs.remove('token');

  // Optional: clear everything
  // await prefs.clear();

  // 🔁 Navigate to Login screen (clear stack)
  Get.offAll(() => const LoginScreen());

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("👋 Logged out successfully"),
      backgroundColor: Colors.green,
    ),
  );
}
