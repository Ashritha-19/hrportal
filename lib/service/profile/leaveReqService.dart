// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRequestProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;

  List<dynamic> leaveList = [];

  /// ================= GET LEAVES =================
  Future<void> fetchLeaveRequests() async {
    print('🟡 fetchLeaveRequests() START');

    isLoading = true;
    notifyListeners();
    print('🔄 isLoading = true');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔑 TOKEN FROM STORAGE => $token');

      if (token == null || token.isEmpty) {
        print('❌ TOKEN IS NULL / EMPTY');
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Apiconstants.baseUrl + Apiconstants.leaveRequestsEndpoint;
      print('➡️ GET URL => $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('⬅️ STATUS CODE => ${response.statusCode}');
      print('📦 RAW RESPONSE => ${response.body}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['status'] == true) {
        leaveList = decoded['data'];
        print('✅ LEAVES FETCHED SUCCESSFULLY');
        print('📊 TOTAL LEAVES => ${leaveList.length}');
      } else {
        print('❌ GET API FAILED');
      }
    } catch (e) {
      print('🔥 GET EXCEPTION => $e');
    }

    isLoading = false;
    notifyListeners();
    print('🔄 isLoading = false');
    print('🟢 fetchLeaveRequests() END');
  }

  /// ================= POST APPLY LEAVE =================
  Future<bool> applyLeave({
    required String leaveType,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    print('🟡 applyLeave() START');

    isSubmitting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('🔑 TOKEN FROM STORAGE => $token');

      if (token == null || token.isEmpty) {
        isSubmitting = false;
        notifyListeners();
        return false;
      }

      final url =
          Apiconstants.baseUrl + Apiconstants.submitLeaveRequestEndpoint;

      final body = {
        "leave_type": leaveType,
        "from_date": fromDate,
        "to_date": toDate,
        "reason": reason,
      };

      print('➡️ POST URL => $url');
      print('📤 POST BODY => $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('⬅️ STATUS CODE => ${response.statusCode}');
      print('📦 RAW RESPONSE => ${response.body}');

      final decoded = json.decode(response.body);

      /// ✅ FIX IS HERE
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['status'] == true) {
        print('🎉 LEAVE APPLIED SUCCESSFULLY');

        await fetchLeaveRequests(); // refresh list

        isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        print('❌ APPLY LEAVE FAILED (STATUS OR RESPONSE)');
      }
    } catch (e) {
      print('🔥 POST EXCEPTION => $e');
    }

    isSubmitting = false;
    notifyListeners();
    return false;
  }
}
