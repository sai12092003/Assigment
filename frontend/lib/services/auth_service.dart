import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  Future<String?> login(String username, String password) async {
    final url = Uri.parse("http://192.168.1.6:5000/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data["access_token"];

        // Save the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);

        return accessToken;
      } else {
        return null;  // Invalid credentials
      }
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }
}
