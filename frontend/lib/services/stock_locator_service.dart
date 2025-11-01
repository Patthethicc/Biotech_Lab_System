import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/api/stock_locator_model.dart';

class StockLocatorService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = const FlutterSecureStorage();

  // Updated method to fetch records with serverside filtering and searching
  Future<List<StockLocator>> searchStockLocators({String? brand, String? query}) async {
    final String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('JWT token not found in secure storage');
    }

    final queryParameters = <String, String>{};
    if (brand != null && brand.isNotEmpty) {
      queryParameters['brand'] = brand;
    }
    if (query != null && query.isNotEmpty) {
      queryParameters['query'] = query;
    }

    final uri = Uri.parse('$baseUrl/stock-locator/search').replace(queryParameters: queryParameters);
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonBody = json.decode(response.body);
      return jsonBody.map((json) => StockLocator.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search stock locators: ${response.statusCode} ${response.body}');
    }
  }

  Future<StockLocator?> searchStockLocator(String brand, String productDescription) async {
    final String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print('Error: JWT token not found in secure storage');
      return null;
    }

    final uri = Uri.parse(baseUrl).replace(
      path: '/stock-locator/search',
      queryParameters: {
        'brand': brand,
        'productDescription': productDescription,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      return StockLocator.fromJson(jsonBody);
    } else if (response.statusCode == 404) {
      print('Stock not found for: $brand / $productDescription');
      return null;
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  Future<StockLocator?> updateStockLocator(StockLocator stockLocator) async {
    final String? token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print('Error: JWT token not found in secure storage');
      return null;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/stock-locator/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(stockLocator.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        return StockLocator.fromJson(jsonBody);
      } else {
        print('Error updating stock locator ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during stock locator update: $e');
      return null;
    }
  }
}