import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/api/item_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ItemDetailsService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<(bool success, String message)> updateItemOnBackend(Item updatedItem) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('$baseUrl/item/v1/updateItem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(updatedItem.toJson()),
      );

      if (response.statusCode == 200) {
        return (true, 'Changes saved successfully!');
      } else {
        return (false, 'Failed to save changes: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return (false, 'Error communicating with backend: $e');
    }
  }

  Future<Item> createInventory(Item item) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.post(
      Uri.parse('$baseUrl/item/v1/addItem'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(item.toJson()),
    );
    return Item.fromJson(json.decode(res.body));
  }

  Future<(bool success, String message)> deleteItem(String itemCode) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.delete(
        Uri.parse('$baseUrl/item/v1/deleteItem/$itemCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return (true, 'Item deleted successfully!');
      } else {
        return (false, 'Failed to delete item: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      return (false, 'Error communicating with backend during delete: $e');
    }
  }
}

