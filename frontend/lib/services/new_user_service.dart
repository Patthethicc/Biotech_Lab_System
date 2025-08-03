import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/new_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewUserService {
  static final String baseUrl = dotenv.env['API_URL']!;
  
  static Future<NewUser> createUser(NewUser user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/v1/addUser'),
      headers: {'Content-Type' : 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      return NewUser.fromJson(responseBody['user']);
    } else {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['message'] ?? 'Failed to create user. Please try again.';
      throw Exception(errorMessage);
    }
  }
}