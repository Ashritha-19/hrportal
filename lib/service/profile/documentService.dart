// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DocumentProvider extends ChangeNotifier {

  bool isLoading = false;

  String empIdProof = "";
  String empAddressProof = "";

  /// ==============================
  /// GET DOCUMENTS
  /// ==============================

  Future<void> fetchDocuments() async {

    isLoading = true;
    notifyListeners();

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Apiconstants.baseUrl + Apiconstants.profile;

      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {

        final json = jsonDecode(res.body)['data'];

        empIdProof = json['empIdProof'] ?? "";
        empAddressProof = json['empAddressProof'] ?? "";

      }

    } catch (e) {

      print("Fetch Documents Error => $e");

    }

    isLoading = false;
    notifyListeners();
  }

  /// ==============================
  /// UPLOAD DOCUMENT
  /// ==============================

  Future<void> uploadDocument({
    required File file,
    required String type,
  }) async {

    try {

      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url =
          "${Apiconstants.baseUrl}/employee/profile/upload-documents";

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      /// ID PROOF
      if (type == "id") {

        request.files.add(
          await http.MultipartFile.fromPath(
            "id_proof",
            file.path,
          ),
        );

      }

      /// ADDRESS PROOF
      else {

        request.files.add(
          await http.MultipartFile.fromPath(
            "address_proof",
            file.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {

        print("Document uploaded successfully");

        await fetchDocuments();

      } else {

        print("Upload failed");
      }

    } catch (e) {

      print("Upload Error => $e");

    }

    isLoading = false;
    notifyListeners();
  }
}