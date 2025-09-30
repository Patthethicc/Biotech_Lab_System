import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InventoryService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Inventory>> fetchStockAlerts(int amt) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/inv/v1/stockAlert/$amt'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory');
    }
  }

  Future<List<Inventory>> getInventories() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/inv/v1/getInv'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory ${response.statusCode}');
    }
  }

  Future<List<Inventory>> getTopStock() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/inv/v1/getTopStock'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed top stocks ${response.statusCode}');
    }
  }

  Future<List<Inventory>> getBottomStock() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/inv/v1/getLowStock'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed low stocks ${response.statusCode}');
    }
  }

  Future<Inventory> createInventory(Inventory inv) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.post(
      Uri.parse('$baseUrl/inv/v1/addInv'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(inv.toJson()),
    );
    return Inventory.fromJson(json.decode(res.body));
  }

  Future<Inventory> updateInventory(Inventory inv) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.put(
      Uri.parse('$baseUrl/inv/v1/updateInv'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      body: json.encode(inv.toJson()),
    );
    return Inventory.fromJson(json.decode(res.body));
  }

  Future<void> deleteInventory(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.delete(Uri.parse('$baseUrl/inv/v1/deleteInv/$id'),
                      headers:{'Authorization': 'Bearer $token'} );

    print(res.statusCode);
    print(res.body);
  }

  Future<Inventory> getInventoryById(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.get(Uri.parse('$baseUrl/inv/v1/getInv/$id'),
                      headers:{'Authorization': 'Bearer $token'});
    return Inventory.fromJson(json.decode(res.body));
  }

  Future<List<Inventory>> getExpiringItems(int days) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/item/v1/getExpiringItems/$days'),
      headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items ${response.statusCode}');
    }
  }
}
