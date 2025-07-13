// File: lib/pages/transaction_entry_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'package:frontend/services/transaction_entry_service.dart';

class TransactionEntryPage extends StatefulWidget {
  const TransactionEntryPage({super.key});

  @override
  State<TransactionEntryPage> createState() => _TransactionEntryPageState();
}

class _TransactionEntryPageState extends State<TransactionEntryPage> {
  final TransactionEntryService _service = TransactionEntryService();
  final TextEditingController _referenceController = TextEditingController();
  late TextEditingController _itemSearchController;
  final TextEditingController _quantityController = TextEditingController();
  List<TransactionEntry> _records = [];

  DateTime? _selectedTransactionDate;
  DateTime? _automaticExpiryDate;
  String? _selectedBrand;
  String? _selectedItemDescription;
  int? _selectedLotNumber;
  String? _selectedStockLocation;
  bool _dontAskAgain = false;

  final List<String> _brands = ['Anbio', 'Biorex', 'Bioelab', 'Bioway', 'Biobase', 'Dymind', 'DH', 'Ediagnosis', 'Genrui',
    'Lifotronic', 'Mindray', 'Olympus', 'Render', 'Rayto', 'Uniper'];
  final List<String> _stockLocations = [
    'Lazcano Ref 1',
    'Lazcano Ref 2', 
    'Gandia (Cold Storage)',
    'Gandia (Ref 1)',
    'Gandia (Ref 2)',
    'Limbaga',
    'Cebu'
  ];

  final Map<String, List<int>> _lotNumbers = {
    'Anbio': [1001, 1002, 1003, 1004],
    'BrandX': [2001, 2002, 2003, 2004],
    'LabCorp': [3001, 3002, 3003, 3004],
    'MediSupply': [4001, 4002, 4003, 4004],
    'ChemTech': [5001, 5002, 5003, 5004],
  };

  final List<String> _allItems = [
    'Laptop Pro 15-inch',
    'Cholesterol 120ml',
    'ALT Test Kit',
    'Blood Glucose Strips',
    'Microscope Slides',
    'Petri Dishes',
    'Lab Gloves',
    'Centrifuge Tubes',
    'Pipette Tips',
    'Chemical Reagents'
  ];

  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final entries = await _service.fetchTransactionEntries();
      setState(() => _records = entries);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  Future<void> _submitData() async {
    final newEntry = {
      "drSIReferenceNum": _referenceController.text,
      "transactionDate": _selectedTransactionDate!.toIso8601String(),
      "brand": _selectedBrand,
      "productDescription": _selectedItemDescription,
      "lotSerialNumber": _selectedLotNumber,
      "expiryDate": _automaticExpiryDate!.toIso8601String(),
      "quantity": int.parse(_quantityController.text),
      "stockLocation": _selectedStockLocation
    };

    final response = await _service.submitTransactionEntry(newEntry);

    if (!mounted) return;
    if (response.statusCode == 200 || response.statusCode == 201) {
      await _fetchRecords();
      _showDialog('Success', 'Transaction data has been successfully submitted!');
    } else {
      _showDialog('Error', 'Failed to submit data. Server responded with ${response.statusCode}.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text('Data Recording')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {}, // TODO: Hook to entry dialog
                child: const Text('Add Entry'),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    border: TableBorder.all(color: Colors.blueGrey, width: 1),
                    columnSpacing: 24.0,
                    horizontalMargin: 12.0,
                    dataRowMaxHeight: double.infinity,
                    headingRowHeight: 56.0,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('DR/SI Reference', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Transaction Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Item Description', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Lot Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Expiry', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Stock Location', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _records.map<DataRow>((data) {
                      return DataRow(
                        cells: [
                          DataCell(Text(data.reference)),
                          DataCell(Text(formatter.format(data.transactionDate))),
                          DataCell(Text(data.brand)),
                          DataCell(Text(data.itemDescription)),
                          DataCell(Text(data.lotNumber.toString())),
                          DataCell(Text(formatter.format(data.expiryDate))),
                          DataCell(Text(data.quantity.toString())),
                          DataCell(Text(data.stockLocation)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
