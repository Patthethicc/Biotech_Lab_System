import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/login_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogInUserService {
  static final String baseUrl = dotenv.env['API_URL']!;
  
  static Future<LogInUser> logInUser(LogInUser user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/v1/login'),
      headers: {'Content-Type' : 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      print(response);
      return LogInUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post data');
    }
  }
}