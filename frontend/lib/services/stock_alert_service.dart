import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/models/api/inventory.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockAlertService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<List<Inventory>> getStockAlerts() async {
    final response = await http.get(
      Uri.parse('${baseUrl}/inv/v1/stockAlert/10'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    List<Inventory> inventoryItems = [];

    if (response.statusCode == 200) {
      var inventory = json.decode(response.body);
      for(var inventoryJson in inventory){
        inventoryItems.add(Inventory.fromJson(inventoryJson));
      }
    } else {
      print(response.body);
      print("error 404");
    }
    return inventoryItems;
  }
}