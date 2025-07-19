import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/login_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogInUserService {
  static final String baseUrl = dotenv.env['API_URL']!;
  
  static Future<LogInUser> logInUser(LogInUser user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/v1/login'),
        headers: {'Content-Type' : 'application/json'},
        body: json.encode(user.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Check if login was successful
        if (responseData['status'] == 'success') {
          return LogInUser.fromJson(responseData);
        } else {
          throw Exception('Login failed: ${responseData['message']}');
        }
      } else if (response.statusCode == 401) {
        final errorData = json.decode(response.body);
        throw Exception('Login failed: ${errorData['message'] ?? 'Invalid credentials'}');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception('Invalid input: ${errorData['message'] ?? 'Bad request'}');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Failed to host lookup') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please check if the backend is running.');
      }
      rethrow;
    }
  }
}