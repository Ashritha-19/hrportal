import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrportal/constants/apiconstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsProvider extends ChangeNotifier {
  bool isLoading = false;

  List<Map<String, dynamic>> projects = [];

  Future<void> fetchProjects() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse(Apiconstants.baseUrl + Apiconstants.projectsEndpoint);

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    final decoded = jsonDecode(response.body);

    // Store FULL project objects
    projects = List<Map<String, dynamic>>.from(decoded["data"]);

    isLoading = false;
    notifyListeners();
  }
}
