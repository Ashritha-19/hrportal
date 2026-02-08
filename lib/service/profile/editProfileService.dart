// ignore_for_file: avoid_print, unnecessary_this

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isUpdating = false;

  // Profile fields (NO MODEL)
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String contact = '';
  String currentAddress = '';
  String permanentAddress = '';

  /// ================= GET PROFILE =================
  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final url = Apiconstants.baseUrl + Apiconstants.profile;

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body)['data'];

        firstName = json['first_name'] ?? '';
        middleName = json['middle_name'] ?? '';
        lastName = json['last_name'] ?? '';
        email = json['empEmail'] ?? '';
        contact = json['empContact'] ?? '';
        currentAddress = json['empCurrentaddr'] ?? '';
        permanentAddress = json['empPermanentaddr'] ?? '';
      }
    } catch (e) {
      print('❌ FETCH ERROR => $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// ================= UPDATE PROFILE =================
  Future<bool> updateProfile({
    required String firstName,
    required String middleName,
    required String lastName,
    required String contact,
    required String currentAddr,
    required String permanentAddr,
  }) async {
    isUpdating = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final url =
          'https://hrportal.eparivartan.com/api/v1/employee/profile/update';

      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll({
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'empContact': contact,
        'empCurrentaddr': currentAddr,
        'empPermanentaddr': permanentAddr,
      });

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      print('📥 UPDATE STATUS => ${response.statusCode}');
      print('📥 UPDATE RESPONSE => $resBody');

      if (response.statusCode == 200) {
        // Update local provider values
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.contact = contact;
        this.currentAddress = currentAddr;
        this.permanentAddress = permanentAddr;

        return true;
      }
    } catch (e) {
      print('🔥 UPDATE ERROR => $e');
    } finally {
      isUpdating = false;
      notifyListeners();
    }

    return false;
  }
}
