import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/census_model.dart';

class ApiService {
  // Use localhost for Windows
  static const String baseUrl = "http://localhost:9090/api"; 

  // 1. LOGIN FUNCTION
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password
        }),
      );

      if (response.statusCode == 200) {
        return response.body; // Returns "ROLE_ADMIN" or "ROLE_ENUMERATOR"
      }
      return null;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 2. SUBMIT CENSUS DATA (SYNC)
  static Future<bool> submitCensus(CensusModel data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/census/submit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "householdId": data.householdId,
          "caste": data.caste,
          "education": data.education,
          "occupation": data.occupation,
          "income": data.income,
          "region": data.region,
          "profileImageBase64": data.profileImageBase64, // Sending the photo!
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Sync Error: $e");
      return false;
    }
  }
}