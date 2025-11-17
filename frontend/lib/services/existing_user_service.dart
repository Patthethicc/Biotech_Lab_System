import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/api/existing_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ExistingUserService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<ExistingUser> getUser() async {
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
      return ExistingUser.fromJson(responseData);
      
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: ${e.message}');
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ExistingUser>> fetchUsers() async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/v1/getUsers'),
      headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => ExistingUser.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
        throw Exception('Invalid JSON response: $e');
    }
  }
}