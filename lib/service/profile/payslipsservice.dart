import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PayslipProvider extends ChangeNotifier {
  bool isLoading = false;
  List payslips = [];

  Future<void> fetchPayslips() async {
    isLoading = true;
    notifyListeners();

    final url = Apiconstants.baseUrl + Apiconstants.payslipsEndpoint;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        payslips = body['data'];
      }
    } catch (e) {
      debugPrint("Payslip Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
