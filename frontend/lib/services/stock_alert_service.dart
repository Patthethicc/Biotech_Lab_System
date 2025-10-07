import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/models/api/inventory.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockAlertService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Inventory>> getStockAlerts(int amount) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/inv/v1/stockAlert/$amount'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    List<Inventory> inventoryItems = [];

    if (response.statusCode == 200) {
      var inventory = json.decode(response.body);
      for(var inventoryJson in inventory){
        inventoryItems.add(Inventory.fromJson(inventoryJson));
      }
    } else {
      throw Exception('Failed to load stock alerts: ${response.statusCode}');
    }
    return inventoryItems;
  }
}