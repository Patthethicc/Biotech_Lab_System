import 'dart:convert';
import 'dart:typed_data';
import 'package:frontend/models/api/combined_entry.dart';
import 'package:http/http.dart' as http;
import '../models/api/transaction_entry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';

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

    CombinedEntry entry = CombinedEntry.fromJson(newEntry);

    final response1 = await http.post(
      Uri.parse('$baseUrl/transaction/createTransactionEntry'),
      headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      body: jsonEncode(entry.toTransactionEntry()),
    );

    await Future.delayed(Duration(seconds: 10));

    final response2 = await http.post(
      Uri.parse('$baseUrl/PO/v1/addPO'),
      headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      body: jsonEncode(entry.toPurchaseOrder()),
    );

    return response1;
  }

  Future<Uint8List?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    return result?.files.first.bytes;
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

  Future<http.Response> deleteTransactionEntry(String id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/transaction/deleteTransactionEntry/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    return response;
  }

  Future<TransactionEntry?> getTransactionById(String id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/transaction/getTransactionByID/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TransactionEntry.fromJson(data);
    } else if (response.statusCode == 404) {
      return null; 
    } else {
      throw Exception('Failed to load transaction: ${response.statusCode}');
    }
  }

  Future<bool> transactionExists(String id) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('$baseUrl/transaction/exists/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check transaction existence: ${response.statusCode}');
    }
  }
}