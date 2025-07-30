import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/api/purchase_order.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class PurchaseOrderService {
  final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.get(Uri.parse('$baseUrl/PO/v1/getPOs'),
      headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => PurchaseOrder.fromJson(json)).toList();
      } else {
        throw NetworkException('Failed to load purchase orders: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw DataParsingException('Invalid JSON response: $e');
      }
      rethrow; 
    }
  }

  Future<void> addPurchaseOrder(PurchaseOrder po) async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PO/v1/addPO'),
        headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(po.toJson()),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw NetworkException('Failed to add purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePurchaseOrder(PurchaseOrder po) async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/PO/v1/updatePO'),
        headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(po.toJson()),
      );
      if (response.statusCode != 200) {
        throw NetworkException('Failed to update purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePurchaseOrder(String purchaseOrderCode) async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/PO/v1/deletePO/$purchaseOrderCode'),
        headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException('Failed to delete purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> downloadFile(String endpointPath) async {
    String? token = await storage.read(key: 'jwt_token');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpointPath'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw NetworkException('File not found or failed to download: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
