import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/api/customer_model.dart';

class CustomerService {
  static final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<Customer>> getCustomers() async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/customer/v1/getCustomer'), // change this for the backend
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers: ${response.body}');
    }
  }

  // check to see if the customer is in the list alr
  Future<bool> customerExists(String name) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/customer/v1/exists?name=${Uri.encodeComponent(name)}'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['exists'] ?? false;
    } else {
      return false;
    }
  }

  Future<http.Response> createCustomer(Map<String, dynamic> customerData) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/customer/v1/addCustomer'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(customerData),
    );
    return response;
  }

  Future<http.Response> updateCustomer(
    String customerId, Map<String, dynamic> customerData) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('$baseUrl/customer/v1/updateCustomer/$customerId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(customerData),
    );
    return response;
  }

  Future<http.Response> deleteCustomer(String customerId) async {
    final String? token = await storage.read(key: 'jwt_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/customer/v1/deleteCustomer/$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}