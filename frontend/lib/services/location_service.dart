import 'dart:convert';
import 'package:frontend/models/api/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocationService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Location>> getLocations() async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.get(Uri.parse('$baseUrl/locations/getLoc'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((json) => Location.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<Location> createLocation(Location loc) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.post(
      Uri.parse('$baseUrl/locations/addLoc'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(loc.toJson()),
    );
    if (res.statusCode == 201) {
      return Location.fromJson(json.decode(res.body));
    } else if (res.statusCode == 409) {
      throw Exception(res.body); 
    } else {
      throw Exception('Failed to create location: ${res.statusCode}');
    }
  }

  Future<Location> updateLocation(String originalName, Location loc) async {
    String? token = await storage.read(key: 'jwt_token');
    final encodedName = Uri.encodeComponent(originalName);
    final res = await http.put(
      Uri.parse('$baseUrl/locations/editLoc/$encodedName'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(loc.toJson()),
    );
    if (res.statusCode == 200) {
      return Location.fromJson(json.decode(res.body));
    } else if (res.statusCode == 409) {
      throw Exception(res.body);
    } else if (res.statusCode == 404) {
      throw Exception('Original location not found.');
    } else {
      throw Exception('Failed to update location: ${res.statusCode}');
    }
  }

  Future<void> deleteLocation(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.delete(Uri.parse('$baseUrl/locations/deleteLoc/$id'),
                      headers:{'Authorization': 'Bearer $token'} );
    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete location');
    }
  }
}