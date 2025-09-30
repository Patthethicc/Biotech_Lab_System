import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/api/edit_user_model.dart';

class EditProfileService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = const FlutterSecureStorage();

  Future<EditUser?> editUser(EditUser user) async {
    final String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print('Error: JWT token not found in secure storage');
      return null;
    }

    final uri = Uri.parse('$baseUrl/user/v1/updateUser');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      return EditUser.fromJson(jsonBody['user']);
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }
}
