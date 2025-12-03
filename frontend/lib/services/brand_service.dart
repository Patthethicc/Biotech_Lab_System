import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BrandService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<BrandModel>> getBrands() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/brand/v1/getBrand'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => BrandModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Brands');
    }
  }

  Future<BrandModel> createBrand(BrandModel brand) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.post(
      Uri.parse('$baseUrl/brand/v1/addBrand'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(brand.toJson()),
    );
    if (res.statusCode == 201) {
      return BrandModel.fromJson(json.decode(res.body));
    } else if (res.statusCode == 409) {
      throw Exception(res.body); 
    } else {
      throw Exception('Failed to create brand: ${res.statusCode}');
    }
  }

  Future<BrandModel> updateBrand(String originalName, BrandModel inv) async {
    String? token = await storage.read(key: 'jwt_token');
    final encodedName = Uri.encodeComponent(originalName);
    final res = await http.put(
      Uri.parse('$baseUrl/brand/v1/updateBrand/$encodedName'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(inv.toJson()),
    );
    if (res.statusCode == 200) {
      return BrandModel.fromJson(json.decode(res.body));
    } else if (res.statusCode == 409) {
      throw Exception(res.body);
    } else if (res.statusCode == 404) {
      throw Exception('Original brand name not found.');
    } else {
      throw Exception('Failed to update brand: ${res.statusCode}');
    }
  }

  Future<void> deleteBrand(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.delete(Uri.parse('$baseUrl/brand/v1/deleteBrand/$id'),
                     headers:{'Authorization': 'Bearer $token'} );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete brand');
    }
  }
}