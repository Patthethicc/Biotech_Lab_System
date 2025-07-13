import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; 
import 'package:frontend/models/api/item_model.dart'; 

const String _backendBaseUrl = 'http://localhost:8080/item/v1'; 

class ItemDetails extends StatefulWidget {
  final Item item;
  final List<String> headers; 

  const ItemDetails({
    Key? key,
    required this.item,
    required this.headers,
  }) : super(key: key);

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  late Map<String, TextEditingController> _controllers;
  final _formKey = GlobalKey<FormState>();

  final List<String> _orderedFieldNames = [
    'itemCode',
    'brand',
    'productDescription',
    'lotSerialNumber',
    'expiryDate',
    'stocksManila',
    'stocksCebu',
    'purchaseOrderReferenceNumber',
    'supplierPackingList',
    'drsiReferenceNumber',
  ];

  @override
  void initState() {
    super.initState();
    _controllers = {};

    _controllers['itemCode'] = TextEditingController(text: widget.item.itemCode);
    _controllers['brand'] = TextEditingController(text: widget.item.brand);
    _controllers['productDescription'] = TextEditingController(text: widget.item.productDescription);
    _controllers['lotSerialNumber'] = TextEditingController(text: widget.item.lotSerialNumber);
    _controllers['expiryDate'] = TextEditingController(
      text: widget.item.expiryDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.item.expiryDate!)
          : '',
    );
    _controllers['stocksManila'] = TextEditingController(text: widget.item.stocksManila);
    _controllers['stocksCebu'] = TextEditingController(text: widget.item.stocksCebu);
    _controllers['purchaseOrderReferenceNumber'] = TextEditingController(text: widget.item.purchaseOrderReferenceNumber);
    _controllers['supplierPackingList'] = TextEditingController(text: widget.item.supplierPackingList);
    _controllers['drsiReferenceNumber'] = TextEditingController(text: widget.item.drsiReferenceNumber);
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateItemOnBackend(Item updatedItem) async {
    try {
      final response = await http.put(
        Uri.parse('$_backendBaseUrl/updateItem'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedItem.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: ${response.statusCode} ${response.body}')),
        );
        print('Backend Error (Update): ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error communicating with backend: $e')),
      );
      print('Network Error (Update): $e');
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog(
        title: 'Confirm Changes',
        content: 'Are you sure you want to save these changes to the server?',
        onConfirm: () {
          DateTime? parsedExpiryDate;
          try {
            if (_controllers['expiryDate']!.text.isNotEmpty) {
              parsedExpiryDate = DateFormat('yyyy-MM-dd').parse(_controllers['expiryDate']!.text);
            }
          } catch (e) {
            print('Error parsing expiry date: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid Expiry Date format. Use YYYY-MM-DD.')),
            );
            return; 
          }

          final Item updatedItem = Item(
            itemCode: _controllers['itemCode']!.text, 
            brand: _controllers['brand']!.text,
            productDescription: _controllers['productDescription']!.text,
            lotSerialNumber: _controllers['lotSerialNumber']!.text,
            expiryDate: parsedExpiryDate,
            stocksManila: _controllers['stocksManila']!.text,
            stocksCebu: _controllers['stocksCebu']!.text,
            purchaseOrderReferenceNumber: _controllers['purchaseOrderReferenceNumber']!.text,
            supplierPackingList: _controllers['supplierPackingList']!.text,
            drsiReferenceNumber: _controllers['drsiReferenceNumber']!.text,
          );

          _updateItemOnBackend(updatedItem);
        },
      );
    }
  }

 
  String _getLabelForField(String fieldName) {
    switch (fieldName) {
      case 'itemCode': return 'Item Code';
      case 'brand': return 'Brand';
      case 'productDescription': return 'Product Description';
      case 'lotSerialNumber': return 'Lot / Serial Number';
      case 'expiryDate': return 'Expiry Date (YYYY-MM-DD)';
      case 'stocksManila': return 'Stocks (Manila)';
      case 'stocksCebu': return 'Stocks (Cebu)';
      case 'purchaseOrderReferenceNumber': return 'PO Reference No.';
      case 'supplierPackingList': return 'Supplier Packing List';
      case 'drsiReferenceNumber': return 'DR/SI Reference No.';
      default: return fieldName; // Fallback
    }
  }

  
  Future<void> _deleteItemOnBackend() async {
    _showConfirmationDialog(
      title: 'Confirm Deletion',
      content: 'Are you sure you want to delete this item? This action cannot be undone.',
      onConfirm: () async {
        try {
          final response = await http.delete(
            Uri.parse('$_backendBaseUrl/deleteItem/${widget.item.itemCode}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );

          if (response.statusCode == 200) { // 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item deleted successfully!')),
            );
            Navigator.of(context).pop(true); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete item: ${response.statusCode} ${response.body}')),
            );
            print('Backend Error (Delete): ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error communicating with backend during delete: $e')),
          );
          print('Network Error (Delete): $e');
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.item.productDescription}'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItemOnBackend, 
            tooltip: 'Delete Item',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Code: ${widget.item.itemCode}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              ..._orderedFieldNames.map((fieldName) {
                bool isItemCodeField = (fieldName == 'itemCode');
                
                
                TextInputType keyboardType = TextInputType.text;
                if (fieldName.toLowerCase().contains('stocks')) { 
                    keyboardType = TextInputType.number;
                } else if (fieldName.toLowerCase().contains('date')) {
                    keyboardType = TextInputType.datetime; 
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _controllers[fieldName],
                    readOnly: isItemCodeField, 
                    decoration: InputDecoration(
                      labelText: _getLabelForField(fieldName),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: isItemCodeField ? Colors.grey[200] : Colors.white, 
                    ),
                    keyboardType: keyboardType,
                    
                    onTap: fieldName == 'expiryDate' ? () async {
                      FocusScope.of(context).requestFocus(new FocusNode()); 
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _controllers['expiryDate']!.text.isNotEmpty
                            ? DateTime.tryParse(_controllers['expiryDate']!.text) ?? DateTime.now()
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _controllers['expiryDate']!.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    } : null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // All fields except expiryDate are required
                        if (fieldName != 'expiryDate') {
                          return 'Please enter ${_getLabelForField(fieldName)}';
                        }
                      }
                
                      if ((fieldName.toLowerCase().contains('stocks')) && value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number for ${_getLabelForField(fieldName)}';
                        }
                      }
                      
                      if (fieldName == 'expiryDate' && value != null && value.isNotEmpty) {
                        try {
                          DateFormat('yyyy-MM-dd').parseStrict(value);
                        } catch (e) {
                          return 'Invalid date format. Use YYYY-MM-DD.';
                        }
                      }
                      return null;
                    },
                  ),
                );
              }).toList(), // Convert iterable to List<Widget>
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}