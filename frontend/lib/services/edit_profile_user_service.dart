import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/edit_user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ExistingEditUserService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<EditUser> getUser() async {
    try {
      final String? token = await storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['sub'] ?? decodedToken['username'];

      final response = await http.get(
        Uri.parse('$baseUrl/user/v1/getUser/id/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load user: ${response.statusCode}');
      }

      final responseData = json.decode(response.body)['user'];
      return EditUser.fromJson(responseData);

    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}