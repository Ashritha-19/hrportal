// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KanbanProvider extends ChangeNotifier {

  final url = Apiconstants.baseUrl + Apiconstants.kanban;

  final String postBaseUrl = Apiconstants.baseUrl + Apiconstants.tasksEndpoint;
      

  bool isLoading = false;

  List<Map<String, dynamic>> upcoming = [];
  List<Map<String, dynamic>> inProgress = [];
  List<Map<String, dynamic>> completed = [];

  /// ================= GET API =================
  Future<void> fetchKanbanTasks() async {
    print("🔥 GET KANBAN START");

    try {
      isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print("🔐 TOKEN => $token");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        upcoming =
            List<Map<String, dynamic>>.from(decoded['data']['todo'] ?? []);

        inProgress =
            List<Map<String, dynamic>>.from(decoded['data']['in_progress'] ?? []);

        completed =
            List<Map<String, dynamic>>.from(decoded['data']['completed'] ?? []);

        print("✅ Upcoming: ${upcoming.length}");
        print("✅ InProgress: ${inProgress.length}");
        print("✅ Completed: ${completed.length}");
      }
    } catch (e) {
      print("❌ GET ERROR => $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= POST UPDATE =================
  Future<void> updateTaskStatus({
    required int id,
    required String status,
    required int position,
  }) async {
    print("🚀 POST UPDATE START");
    print("🆔 ID: $id");
    print("📌 STATUS: $status");
    print("📍 POSITION: $position");

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$postBaseUrl/$id/status"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "status": status,
          "position": position,
        }),
      );

      print("📡 POST STATUS: ${response.statusCode}");
      print("📦 POST BODY: ${response.body}");
    } catch (e) {
      print("❌ POST ERROR => $e");
    }
  }

  /// ================= MOVE TASK =================
  Future<void> moveTask({
    required Map<String, dynamic> task,
    required String newStatus,
    required int newIndex,
  }) async {

    print("🟡 MOVE TASK => ${task['title']}");
    print("➡ New Status: $newStatus");
    print("➡ New Index: $newIndex");

    // Remove from all lists
    upcoming.removeWhere((e) => e['id'] == task['id']);
    inProgress.removeWhere((e) => e['id'] == task['id']);
    completed.removeWhere((e) => e['id'] == task['id']);

    // Add to correct list
    if (newStatus == "todo") {
      upcoming.insert(newIndex, task);
    } else if (newStatus == "progress") {
      inProgress.insert(newIndex, task);
    } else {
      completed.insert(newIndex, task);
    }

    notifyListeners();

    await updateTaskStatus(
      id: task['id'],
      status: newStatus,
      position: newIndex,
    );
  }
}