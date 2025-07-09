import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/models/api/inventory.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockAlertService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<List<Inventory>> getStockAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/inv/v1/stockAlert'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Inventory.fromJson(json)).toList();
  }
}