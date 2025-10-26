import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/api/inventory_payload.dart';

class StockAlertService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

    Future<List<InventoryPayload>> getStockAlerts() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/inv/v1/stockAlert/10'),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => InventoryPayload.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stock alerts: ${response.statusCode} ${response.body}');
    }
  }
}