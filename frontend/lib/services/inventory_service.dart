import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/api/inventory.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class Inventory {
//   final int inventoryId;
//   final String itemCode;
//   final int quantityOnHand;
//   final String lastUpdated;

//   Inventory({
//     required this.inventoryId,
//     required this.itemCode,
//     required this.quantityOnHand,
//     required this.lastUpdated,
//   });

//   factory Inventory.fromJson(Map<String, dynamic> json) {
//     return Inventory(
//       inventoryId: json['inventoryId'],
//       itemCode: json['itemCode'],
//       quantityOnHand: json['quantityOnHand'],
//       lastUpdated: json['lastUpdated'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'inventoryId': inventoryId,
//       'itemCode': itemCode,
//       'quantityOnHand': quantityOnHand,
//       'lastUpdated': lastUpdated,
//     };
//   }
// }

class InventoryService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Inventory>> fetchStockAlerts(int amt) async {
    final response = await http.get(Uri.parse('$baseUrl/inv/v1/stockAlert/$amt'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Inventory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory');
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
    await http.delete(Uri.parse('$baseUrl/inv/v1/deleteInv/$id'),
                      headers:{'Authorization': 'Bearer $token'} );
  }

  Future<Inventory> getInventoryById(int id) async {
    String? token = await storage.read(key: 'jwt_token');
    final res = await http.get(Uri.parse('$baseUrl/inv/v1/getInv/$id'),
                      headers:{'Authorization': 'Bearer $token'});
    return Inventory.fromJson(json.decode(res.body));
  }
}
