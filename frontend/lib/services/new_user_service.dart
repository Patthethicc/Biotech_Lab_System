import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/new_user.dart';

class NewUserService {
  static const String baseUrl = '$API_URL/user/v1';
  
  static Future<NewUser> createUser(NewUser user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addUser'),
      headers: {'Content-Type' : 'application/json'},
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return NewUser.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to post data');
    }
  }
}