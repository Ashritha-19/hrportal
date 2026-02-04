import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubmitReportProvider extends ChangeNotifier {
  bool isSubmitting = false;

  Future<bool> submitReport({
    required String projectId,
    required String taskDescription,
    required String hoursWorked,
    required String reportDate,
    required String workType,
  }) async {
    isSubmitting = true;
    notifyListeners();

    debugPrint("📤 SUBMIT REPORT API CALLED");
    debugPrint("➡️ projectId      : $projectId");
    debugPrint("➡️ taskDescription: $taskDescription");
    debugPrint("➡️ hoursWorked    : $hoursWorked");
    debugPrint("➡️ reportDate     : $reportDate");
    debugPrint("➡️ workType       : $workType");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      debugPrint("🔑 TOKEN FROM STORAGE: $token");

      if (token == null || token.isEmpty) {
        debugPrint("❌ TOKEN NOT FOUND OR EMPTY");
        isSubmitting = false;
        notifyListeners();
        return false;
      }
      final url = Uri.parse(
        Apiconstants.baseUrl + Apiconstants.submitReportEndpoint,
      );

      debugPrint("🌐 API URL: $url");

      final payload = {
        "project_id": projectId,
        "task_description": taskDescription,
        "hours_worked": hoursWorked,
        "report_date": reportDate,
        "work_type": workType,
      };

      debugPrint("📦 REQUEST BODY: ${jsonEncode(payload)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      debugPrint("📥 RESPONSE STATUS CODE: ${response.statusCode}");
      debugPrint("📥 RESPONSE BODY: ${response.body}");

      final decoded = jsonDecode(response.body);

      debugPrint("✅ DECODED RESPONSE: $decoded");

      isSubmitting = false;
      notifyListeners();

      final success = response.statusCode == 201 && decoded["status"] == true;

      debugPrint(
        success
            ? "🎉 REPORT SUBMITTED SUCCESSFULLY"
            : "❌ REPORT SUBMISSION FAILED (API RESPONSE)",
      );

      return success;
    } catch (e, stackTrace) {
      debugPrint("🔥 SUBMIT REPORT EXCEPTION");
      debugPrint("❌ ERROR: $e");
      debugPrint("📍 STACK TRACE: $stackTrace");

      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
