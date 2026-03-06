// ignore_for_file: avoid_print, unnecessary_this, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:hrportal/service/dashboard/dashboardservice.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isUpdating = false;

  /// Profile Image
  String profileImage = '';

  /// Profile fields
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String contact = '';
  String currentAddress = '';
  String permanentAddress = '';
  String empIdProof = '';
  String empAddressProof = '';

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

      print("PROFILE RESPONSE => ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body)['data'];

        firstName = json['first_name'] ?? '';
        middleName = json['middle_name'] ?? '';
        lastName = json['last_name'] ?? '';
        email = json['empEmail'] ?? '';
        contact = json['empContact'] ?? '';
        currentAddress = json['empCurrentaddr'] ?? '';
        permanentAddress = json['empPermanentaddr'] ?? '';

        empIdProof = json['empIdProof'] ?? '';
        empAddressProof = json['empAddressProof'] ?? '';

        /// Convert relative path → full URL
        if (json['profile_image'] != null &&
            json['profile_image'].toString().isNotEmpty) {
          profileImage =
              "https://hrportal.eparivartan.com/${json['profile_image']}";
        } else {
          profileImage = '';
        }
      }
    } catch (e) {
      print('FETCH PROFILE ERROR => $e');
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

      final url = Apiconstants.baseUrl + Apiconstants.updateProfileEndpoint;

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

      print('UPDATE STATUS => ${response.statusCode}');
      print('UPDATE RESPONSE => $resBody');

      if (response.statusCode == 200) {
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.contact = contact;
        this.currentAddress = currentAddr;
        this.permanentAddress = permanentAddr;

        return true;
      }
    } catch (e) {
      print('UPDATE ERROR => $e');
    } finally {
      isUpdating = false;
      notifyListeners();
    }

    return false;
  }

  /// ================= UPLOAD PROFILE IMAGE =================
  Future<bool> uploadProfileImage(BuildContext context, File imageFile) async {
    try {
      print("Starting profile image upload...");

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final url =
          Apiconstants.baseUrl + Apiconstants.uploadProfileImageEndpoint;

      print("UPLOAD API => $url");

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imageFile.path),
      );

      var response = await request.send();

      var responseBody = await response.stream.bytesToString();

      print("UPLOAD RESPONSE CODE => ${response.statusCode}");
      print("UPLOAD RESPONSE BODY => $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        profileImage = data['data']['profile_image_url'] ?? '';

        /// refresh profile
        await fetchProfile();

        /// refresh dashboard
        context.read<DashboardProvider>().fetchDashboard();

        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile image updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload image"),
            backgroundColor: Colors.red,
          ),
        );

        return false;
      }
    } catch (e) {
      print("UPLOAD ERROR => $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));

      return false;
    }
  }
}
