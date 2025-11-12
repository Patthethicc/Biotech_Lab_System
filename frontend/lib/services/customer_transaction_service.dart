import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/api/customer_transaction_model.dart';

class CustomerTransactionService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getItemsForBrand(String brandId) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/items/v1/$brandId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load items for brand');
    }
  }

  Future<Map<String, dynamic>> getItemDetails(String itemId) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/items/details/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load item details');
    }
  }

  Future<http.Response> createCustomerTransaction(CustomerTransaction transaction) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/sales/v1/createTransaction'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(transaction.toJson()),
    );
    return response;
  }

  Future<List<CustomerTransaction>> getCustomerTransactions() async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/sales/v1/getTransactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => CustomerTransaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customer transactions');
    }
  }

  Future<http.Response> deleteCustomerTransaction(String transactionId) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/sales/v1/deleteTransaction/$transactionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}