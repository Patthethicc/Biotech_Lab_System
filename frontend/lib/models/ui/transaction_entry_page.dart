// File: lib/pages/transaction_entry_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 

class TransactionEntryPage extends StatefulWidget {
  const TransactionEntryPage({super.key});
  @override
  State<TransactionEntryPage> createState() => _TransactionEntryPageState();
}

class _TransactionEntryPageState extends State<TransactionEntryPage> {
  final TransactionEntryService _service = TransactionEntryService();
  final TextEditingController _referenceController = TextEditingController();
  late final TextEditingController _itemSearchController;
  final TextEditingController _quantityController = TextEditingController();
  List<TransactionEntry> _records = [];

  DateTime? _selectedTransactionDate;
  DateTime? _automaticExpiryDate;
  String? _selectedBrand;
  String? _selectedItemDescription;
  int? _selectedLotNumber;
  String? _selectedStockLocation;
  bool _dontAskAgain = false;
  TransactionEntry? _selectedEntryForEdit;

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
    'Biorex': [2001, 2002, 2003, 2004], 
    'Bioelab': [3001, 3002, 3003, 3004], 
    'Bioway': [4001, 4002, 4003, 4004], 
    'Biobase': [5001, 5002, 5003, 5004], 
    'Dymind': [6001, 6002, 6003, 6004],
    'DH': [7001, 7002, 7003, 7004],
    'Ediagnosis': [8001, 8002, 8003, 8004],
    'Genrui': [9001, 9002, 9003, 9004],
    'Lifotronic': [10001, 10002, 10003, 10004],
    'Mindray': [11001, 11002, 11003, 11004],
    'Olympus': [12001, 12002, 12003, 12004],
    'Render': [13001, 13002, 13003, 13004],
    'Rayto': [14001, 14002, 14003, 14004],
    'Uniper': [15001, 15002, 15003, 15004],
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

  List<String> _filteredItems = [];
  @override
  void initState() {
    super.initState();
    _itemSearchController = TextEditingController();
    _fetchRecords();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _itemSearchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecords() async {
    try {
      final entries = await _service.fetchTransactionEntries();
      setState(() {
        _records = entries // sorting
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        _showDialog('Error', 'Failed to load transaction data: $e');
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _calculateExpiryDate() {
    if (_selectedBrand != null && _selectedItemDescription != null && _allItems.contains(_selectedItemDescription)) {
      setState(() {
        _automaticExpiryDate = DateTime.now().add(const Duration(days: 730));
      });
    } else {
      setState(() {
        _automaticExpiryDate = null;
      });
    }
  }

  Future<void> _submitData() async {
    if (_selectedTransactionDate == null || _selectedBrand == null ||
        _selectedItemDescription == null || _selectedLotNumber == null ||
        _automaticExpiryDate == null || _selectedStockLocation == null ||
        int.tryParse(_quantityController.text) == null) {
      _showErrorDialog(['One or more fields are missing or invalid.']);
      return;
    }
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

    debugPrint(jsonEncode(newEntry)); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Submitting...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while data is being submitted.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.submitTransactionEntry(newEntry);

      if (!mounted) return;

      Navigator.of(context).pop(); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchRecords(); 
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Transaction data has been successfully submitted!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to submit data. Server responded with ${response.statusCode}: ${response.body}.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred: $e');
    }
  }

  void _showAddEntryDialog() {
    _referenceController.clear();
    _itemSearchController.clear();
    _quantityController.clear();
    _selectedTransactionDate = null;
    _automaticExpiryDate = null;
    _selectedBrand = null;
    _selectedItemDescription = null;
    _selectedLotNumber = null;
    _selectedStockLocation = null;
    _filteredItems = _allItems; 

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Transaction Entry'),
              content: SizedBox(
                width: 500, 
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'DR/SI Reference',
                          hintText: 'Enter reference number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000), 
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTransactionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Transaction Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedTransactionDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!)
                                : 'Select transaction date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        items: _brands.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBrand = newValue;
                            _selectedLotNumber = null; 
                          });
                          _calculateExpiryDate();
                        },
                      ),
                      const SizedBox(height: 16),

                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return _allItems.where((String option) {
                            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          setState(() { 
                            _selectedItemDescription = selection;
                            _itemSearchController.text = selection; 
                          });
                          _calculateExpiryDate();
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Item Description',
                              hintText: 'Type or select an item',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            onChanged: (text) {
                                setState(() { 
                                  _selectedItemDescription = text;
                                });
                            },
                          );
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.5, 
                                ), 
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        value: _selectedLotNumber,
                        decoration: const InputDecoration(
                          labelText: 'Lot Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.arrow_drop_down), 
                        ),
                        items: _selectedBrand != null && _lotNumbers.containsKey(_selectedBrand)
                            ? _lotNumbers[_selectedBrand]!.map((int lotNumber) {
                                return DropdownMenuItem<int>(
                                  value: lotNumber,
                                  child: Text(lotNumber.toString()),
                                );
                              }).toList()
                            : [], 
                        onChanged: _selectedBrand != null && _lotNumbers.containsKey(_selectedBrand)
                            ? (int? newValue) {
                                setState(() { 
                                  _selectedLotNumber = newValue;
                                });
                                _calculateExpiryDate();
                              }
                            : null, 
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _automaticExpiryDate ?? DateTime.now().add(const Duration(days: 730)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _automaticExpiryDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiration Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _automaticExpiryDate != null
                                ? DateFormat('yyyy-MM-dd').format(_automaticExpiryDate!)
                                : 'Select expiration date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter quantity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit), 
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedStockLocation,
                        decoration: const InputDecoration(
                          labelText: 'Stock Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: _stockLocations.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStockLocation = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _validateAndSubmit();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _validateAndSubmit() {
    List<String> errors = [];

    if (_referenceController.text.trim().isEmpty) {
      errors.add('DR/SI Reference is required');
    }
    if (_selectedTransactionDate == null) {
      errors.add('Transaction Date is required');
    }
    if (_selectedBrand == null) {
      errors.add('Brand is required');
    }
    if (_selectedItemDescription == null || _selectedItemDescription!.isEmpty) {
      errors.add('Item Description is required');
    }
    if (_selectedBrand != null && !_lotNumbers.containsKey(_selectedBrand)) {
      errors.add('Lot numbers are not defined for the selected brand.');
    }
    if (_selectedLotNumber == null) {
      errors.add('Lot Number is required');
    }
    if (_automaticExpiryDate == null) {
      errors.add('Expiry Date is required');
    }
    if (_quantityController.text.trim().isEmpty) {
      errors.add('Quantity is required');
    } else if (int.tryParse(_quantityController.text) == null || int.parse(_quantityController.text) <= 0) {
      errors.add('Quantity must be a valid positive number');
    }
    if (_selectedStockLocation == null) {
      errors.add('Stock Location is required');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    if (!_dontAskAgain) {
      _showConfirmationDialog();
    } else {
      Navigator.of(context).pop();
      _submitData();
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

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please correct the following errors:'),
              const SizedBox(height: 8),
              ...errors.map((error) => Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                child: Text('• $error', style: const TextStyle(color: Colors.red)),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Data Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please confirm the following data:'),
                  const SizedBox(height: 12),
                  Text('Reference: ${_referenceController.text}'),
                  Text('Transaction Date: ${_selectedTransactionDate != null ? DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!) : 'N/A'}'),
                  Text('Brand: ${_selectedBrand ?? 'N/A'}'),
                  Text('Item: ${_selectedItemDescription ?? 'N/A'}'),
                  Text('Lot Number: ${_selectedLotNumber?.toString() ?? 'N/A'}'),
                  Text('Expiry Date: ${_automaticExpiryDate != null ? DateFormat('yyyy-MM-dd').format(_automaticExpiryDate!) : 'N/A'}'),
                  Text('Quantity: ${_quantityController.text.isNotEmpty ? _quantityController.text : 'N/A'}'),
                  Text('Stock Location: ${_selectedStockLocation ?? 'N/A'}'),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Do not ask me again'),
                    value: _dontAskAgain,
                    onChanged: (bool? value) {
                      setState(() { 
                        _dontAskAgain = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitData();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEntryDialog(TransactionEntry entry) {
    _referenceController.text = entry.reference;
    _selectedTransactionDate = entry.transactionDate;
    _selectedBrand = entry.brand;
    _itemSearchController.text = entry.itemDescription;
    _selectedItemDescription = entry.itemDescription;
    _selectedLotNumber = int.tryParse(entry.lotNumber); 
    _automaticExpiryDate = entry.expiryDate;
    _quantityController.text = entry.quantity.toString();
    _selectedStockLocation = entry.stockLocation;
    _filteredItems = _allItems; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Transaction Entry'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'DR/SI Reference',
                          hintText: 'Enter reference number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedTransactionDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTransactionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Transaction Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedTransactionDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!)
                                : 'Select transaction date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        items: _brands.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBrand = newValue;
                            _selectedLotNumber = null;
                          });
                          _calculateExpiryDate();
                        },
                      ),
                      const SizedBox(height: 16),

                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return _allItems.where((String option) {
                            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            _selectedItemDescription = selection;
                            _itemSearchController.text = selection;
                          });
                          _calculateExpiryDate();
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                          _itemSearchController = fieldTextEditingController;
                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Item Description',
                              hintText: 'Type or select an item',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            onChanged: (text) {
                                setState(() {
                                  _selectedItemDescription = text;
                                });
                            },
                          );
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        title: Text(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        value: _selectedLotNumber,
                        decoration: const InputDecoration(
                          labelText: 'Lot Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        items: _selectedBrand != null && _lotNumbers.containsKey(_selectedBrand)
                            ? _lotNumbers[_selectedBrand]!.map((int lotNumber) {
                                return DropdownMenuItem<int>(
                                  value: lotNumber,
                                  child: Text(lotNumber.toString()),
                                );
                              }).toList()
                            : [],
                        onChanged: _selectedBrand != null && _lotNumbers.containsKey(_selectedBrand)
                            ? (int? newValue) {
                                setState(() {
                                  _selectedLotNumber = newValue;
                                });
                                _calculateExpiryDate();
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _automaticExpiryDate ?? DateTime.now().add(const Duration(days: 730)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _automaticExpiryDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiration Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _automaticExpiryDate != null
                                ? DateFormat('yyyy-MM-dd').format(_automaticExpiryDate!)
                                : 'Select expiration date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter quantity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedStockLocation,
                        decoration: const InputDecoration(
                          labelText: 'Stock Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: _stockLocations.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStockLocation = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectedEntryForEdit = null; 
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _validateAndSubmitEdit(entry.reference);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectEntryForEdit(TransactionEntry entry) {
    setState(() {
      _selectedEntryForEdit = entry;
    });
    _showEditEntryDialog(entry);
  }

  void _validateAndSubmitEdit(String entryId) {
    List<String> errors = [];

    if (_referenceController.text.trim().isEmpty) {
      errors.add('DR/SI Reference is required');
    }
    if (_selectedTransactionDate == null) {
      errors.add('Transaction Date is required');
    }
    if (_selectedBrand == null) {
      errors.add('Brand is required');
    }
    if (_selectedItemDescription == null || _selectedItemDescription!.isEmpty) {
      errors.add('Item Description is required');
    }
    if (_selectedBrand != null && !_lotNumbers.containsKey(_selectedBrand)) {
      errors.add('Lot numbers are not defined for the selected brand.');
    }
    if (_selectedLotNumber == null) {
      errors.add('Lot Number is required');
    }
    if (_automaticExpiryDate == null) {
      errors.add('Expiry Date is required');
    }
    if (_quantityController.text.trim().isEmpty) {
      errors.add('Quantity is required');
    } else if (int.tryParse(_quantityController.text) == null || int.parse(_quantityController.text) <= 0) {
      errors.add('Quantity must be a valid positive number');
    }
    if (_selectedStockLocation == null) {
      errors.add('Stock Location is required');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    Navigator.of(context).pop();
    _updateData(entryId);
  }

  Future<void> _updateData(String entryId) async {
    final updatedEntry = {
      "drSIReferenceNum": _referenceController.text,
      "transactionDate": _selectedTransactionDate!.toIso8601String(),
      "brand": _selectedBrand,
      "productDescription": _selectedItemDescription,
      "lotSerialNumber": _selectedLotNumber,
      "expiryDate": _automaticExpiryDate!.toIso8601String(),
      "quantity": int.parse(_quantityController.text),
      "stockLocation": _selectedStockLocation
    };

    debugPrint('Updating: ${jsonEncode(updatedEntry)}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Updating...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while data is being updated.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.updateTransactionEntry(entryId, updatedEntry);

      if (!mounted) return;

      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        await _fetchRecords(); 
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Transaction data has been successfully updated!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          _selectedEntryForEdit = null; 
        });
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update data. Server responded with ${response.statusCode}: ${response.body}.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred during update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Recording'),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddEntryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _selectedEntryForEdit == null 
                        ? null 
                        : () {
                            _showEditEntryDialog(_selectedEntryForEdit!);
                          },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Selected Entry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
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
                    rows: _records.isEmpty
                        ? <DataRow>[]
                        : _records.map<DataRow>((data) {
                            final isSelected = _selectedEntryForEdit == data; 
                            return DataRow(
                              selected: isSelected,
                              onSelectChanged: (bool? selected) {
                                setState(() {
                                  if (selected != null && selected) {
                                    _selectedEntryForEdit = data;
                                  } else {
                                    _selectedEntryForEdit = null;
                                  }
                                });
                              },
                              cells: [
                                DataCell(SizedBox(width: 100, child: Text(data.reference, softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 90, child: Text(formatter.format(data.transactionDate), softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 85, child: Text(data.brand, softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 120, child: Text(data.itemDescription, softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 80, child: Text(data.lotNumber, softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 90, child: Text(formatter.format(data.expiryDate), softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 60, child: Text(data.quantity.toString(), softWrap: true, style: const TextStyle(height: 1.2,)))),
                                DataCell(SizedBox(width: 100, child: Text(data.stockLocation, softWrap: true, style: const TextStyle(height: 1.2,)))),
                              ],
                            );
                          }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
