// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OvertimeProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;

  List<Map<String, dynamic>> overtimeList = [];

  /// ============================
  /// GET OVERTIME HISTORY
  /// ============================
  Future<void> fetchOvertime() async {
    isLoading = true;
    notifyListeners();

    print('🟡 fetchOvertime START');

    final url = Apiconstants.baseUrl + Apiconstants.overTimeRequestsEndpoint;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔑 TOKEN FROM STORAGE => $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟢 STATUS CODE => ${response.statusCode}');
      print('📦 RESPONSE => ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == true) {
          overtimeList = List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (e) {
      print('❌ fetchOvertime ERROR => $e');
    }

    isLoading = false;
    notifyListeners();

    print('🟢 fetchOvertime END');
  }

  /// ============================
  /// POST OVERTIME REQUEST
  /// ============================
  Future<bool> submitOvertime({
    required String otDate,
    required String otHours,
    required String reason,
    required int projectId,
    required String otType,
    required String workType,
  }) async {
    isSubmitting = true;
    notifyListeners();

    print('🟡 submitOvertime START');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔑 TOKEN FROM STORAGE => $token');

      final url =
          Apiconstants.baseUrl + Apiconstants.submitOverTimeRequestEndpoint;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "ot_date": otDate,
          "ot_hours": otHours,
          "reason": reason,
          "project_id": projectId,
          "ot_type": otType,
          "work_type": workType,
        }),
      );

      print('🟢 STATUS CODE => ${response.statusCode}');
      print('📦 RESPONSE => ${response.body}');

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 && decoded['status'] == true) {
        print('✅ Overtime submitted successfully');

        /// 🔥 refresh history immediately
        await fetchOvertime();
        return true;
      }
    } catch (e) {
      print('❌ submitOvertime ERROR => $e');
    } finally {
      isSubmitting = false;
      notifyListeners();
      print('🟢 submitOvertime END');
    }

    return false;
  }
}
