// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  bool isLoading = false;

  List<Map<String, dynamic>> notifications = [];
  int unreadCount = 0;

  final String url =
      Apiconstants.baseUrl + Apiconstants.notificationsEndpoint;

  /* ==========================================================
     🔔 FETCH NOTIFICATIONS (GET)
     ========================================================== */
  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result["status"] == true) {
        notifications = List<Map<String, dynamic>>.from(result["data"]);

        _calculateUnreadCount();
      }
    } catch (e) {
      print("❌ Fetch Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* ==========================================================
     📖 MARK AS READ (POST)
     ========================================================== */
  Future<void> readNotification(int index) async {
    try {
      final notification = notifications[index];

      if (notification["is_read"] == 1) return;

      final int id = notification["id"];

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("${Apiconstants.baseUrl}notifications/$id/read"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result["status"] == true) {
        notifications[index]["is_read"] = 1;

        _calculateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      print("❌ Read Error: $e");
    }
  }

  /* ==========================================================
     🗑 DELETE NOTIFICATION (DELETE)
     ========================================================== */
  Future<bool> deleteNotification(int index) async {
    try {
      final notification = notifications[index];
      final int id = notification["id"];
      final bool wasUnread = notification["is_read"] == 0;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("${Apiconstants.baseUrl}notifications/$id/delete"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final result = json.decode(response.body);

      if (response.statusCode == 200 && result["status"] == true) {
        notifications.removeAt(index);

        if (wasUnread) {
          unreadCount--;
        }

        notifyListeners();

        return true; // ✅ success
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Delete Error: $e");
      return false;
    }
  }

  /* ==========================================================
     🔢 CALCULATE UNREAD
     ========================================================== */
  void _calculateUnreadCount() {
    unreadCount = notifications.where((n) => n["is_read"] == 0).length;
  }
}
