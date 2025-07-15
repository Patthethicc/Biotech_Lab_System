import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api/transaction_entry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionEntryService {
  final String baseUrl = dotenv.env['API_URL']!;
  final storage = FlutterSecureStorage();

  Future<List<TransactionEntry>> fetchTransactionEntries() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(Uri.parse('$baseUrl/transaction/all'),
    headers:{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => TransactionEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<http.Response> submitTransactionEntry(Map<String, dynamic> newEntry) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/transaction/createTransactionEntry'),
      headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      body: jsonEncode(newEntry),
    );
    return response;
  }

  Future<http.Response> updateTransactionEntry(String id, Map<String, dynamic> updatedEntry) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('$baseUrl/transaction/updateTransaction/$id'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(updatedEntry),
    );
    return response;
  }
}