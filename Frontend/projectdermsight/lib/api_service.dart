import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "https://dermproject.onrender.com";
  // ---------------- REGISTER ----------------
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String age,
    required String password,
  }) async {

    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "age": age,
        "password": password,
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {

    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  //----------google sign in ------------

  static Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String name,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/google-login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "name": name,
      }),
    );

    return jsonDecode(response.body);
  }

  //-----------getprofile---------

  static Future<Map<String, dynamic>> getProfile(String token) async {

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  //  UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String email,
    required String age,
    String? password,
  }) async {

    final url = Uri.parse("$baseUrl/update-profile");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "age": age,
        "password": password,
      }),
    );

    print("UPDATE STATUS: ${response.statusCode}");
    print("UPDATE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "msg": "Error updating profile",
        "error": response.body
      };
    }
  }

  // ============================
  // 🔹 IMAGE ANALYSIS
  // ============================
  static Future<Map<String, dynamic>> analyzeImage(
      File image, String token) async {

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/analyze-image"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    print("IMAGE STATUS = ${res.statusCode}");
    print("IMAGE BODY = ${res.body}");

    return jsonDecode(res.body);

  }

  // ============================
  //  TEXT ANALYSIS
  // ============================
  static Future<Map<String, dynamic>> analyzeText(
      String text, String token) async {

    final response = await http.post(
      Uri.parse("$baseUrl/analyze-text"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "text": text,
      }),
    );
    print("TOKEN = $token");
    print("STATUS = ${response.statusCode}");
    print("BODY = ${response.body}");

    return jsonDecode(response.body);
  }

  // ============================
  //  COMBINED ANALYSIS
  // ============================
  static Future<Map<String, dynamic>> analyzeCombined(
      File image, String text, String token) async {

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/analyze-combined"),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    request.fields['text'] = text;

    print("COMBINED REQUEST STARTED");

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    print("COMBINED STATUS = ${res.statusCode}");
    print("COMBINED BODY = ${res.body}");

    return jsonDecode(res.body);
  }

  // ============================
  //  SAVE SCAN
  // ============================
  static Future<void> saveScan(
      Map<String, dynamic> data, String token) async {

    await http.post(
      Uri.parse("$baseUrl/save-scan"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
  }

  // ============================
  //  HISTORY
  // ============================
  static Future<List<dynamic>> getHistory(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("HISTORY RESPONSE: ${response.body}");

      // Ensure it's always List
      if (data is List) {
        return data;
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to load history: ${response.statusCode}");
    }
  }}