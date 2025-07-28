import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/api/brand.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BrandService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Brand>> getBrands() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/brand/v1/getBrand'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Brand');
    }
  }

  Future<Brand> createBrand(Brand brand) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.post(
      Uri.parse('$baseUrl/brand/v1/addBrand'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(brand.toJson()),
    );
    return Brand.fromJson(json.decode(res.body));
  }

  Future<Brand> updateBrand(Brand inv) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.put(
      Uri.parse('$baseUrl/brand/v1/updateBrand'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(inv.toJson()),
    );
    return Brand.fromJson(json.decode(res.body));
  }

  Future<void> deleteBrand(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    await http.delete(Uri.parse('$baseUrl/brand/v1/deleteBrand/$id'),
                      headers:{'Authorization': 'Bearer $token'} );
  }

  Future<Brand> getBrandById(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.get(Uri.parse('$baseUrl/brand/v1/getBrand/$id'),
                      headers:{'Authorization': 'Bearer $token'});
    return Brand.fromJson(json.decode(res.body));
  }
}