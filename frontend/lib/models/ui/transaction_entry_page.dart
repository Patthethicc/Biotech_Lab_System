import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'dart:convert'; 

class _NeumorphicNavButton extends StatefulWidget {
  const _NeumorphicNavButton({
    Key? key,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_NeumorphicNavButton> createState() => _NeumorphicNavButtonState();
}

class _NeumorphicNavButtonState extends State<_NeumorphicNavButton> {
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant _NeumorphicNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _isHovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;

    return MouseRegion(
      onEnter: (_) {
        if (isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isEnabled) setState(() => _isHovered = false);
      },
      child: NeumorphicButton(
        onPressed: isEnabled ? widget.onPressed : null,
        style: NeumorphicStyle(
          depth: _isHovered && isEnabled ? -3 : 3,
          intensity: 0.8,
          surfaceIntensity: 0.5,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(50)),
          lightSource: LightSource.topLeft,
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(
          widget.icon,
          color: isEnabled ? Colors.lightBlue[400] : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
} 

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
  final TextEditingController _searchController = TextEditingController();
  List<TransactionEntry> _records = [];
  List<TransactionEntry> _allRecords = [];
  List<TransactionEntry> _displayRecords = [];
  bool _isLoading = true;
  bool _isHovered = false;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000];
  final int _showAllValue = -1;

  DateTime? _selectedTransactionDate;
  DateTime? _automaticExpiryDate;
  String? _selectedBrand;
  String? _selectedItemDescription;
  int? _selectedLotNumber;
  String? _selectedStockLocation;
  bool _dontAskAgain = false;
  TransactionEntry? _selectedEntryForEdit;
  Set<TransactionEntry> _selectedEntries = {};
  bool _selectAll = false;

  bool _isValidatingReference = false;
  bool _referenceExists = false;
  String? _referenceError;

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

  List<String> _allItems = [
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
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _itemSearchController.dispose();
    _quantityController.dispose();
    _searchController.removeListener(_filterRecords);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final entries = await _service.fetchTransactionEntries();
      setState(() {
        _records.clear();
        _allRecords.clear();
        _displayRecords.clear();
        _selectedEntries.clear();
        _selectedEntryForEdit = null;
        _selectAll = false;
        
        _records = entries
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _allRecords = List.from(_records);
        _displayRecords = List.from(_allRecords);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching data: $e');
      if (mounted) {
        _showDialog('Error', 'Failed to load transaction data: $e');
      }
    }
  }

  Future<void> _validateReference(String reference) async {
    if (reference.trim().isEmpty) {
      setState(() {
        _isValidatingReference = false;
        _referenceExists = false;
      });
      return;
    }

    setState(() {
      _isValidatingReference = true;
    });

    try {
      final exists = await _service.transactionExists(reference.trim());
      setState(() {
        _isValidatingReference = false;
        _referenceExists = exists;
      });
    } catch (e) {
      setState(() {
        _isValidatingReference = false;
        _referenceExists = false;
      });
      debugPrint('Error validating reference: $e');
    }
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayRecords = _allRecords.where((record) {
          final referenceMatch = record.reference.toLowerCase().contains(query);
          final brandMatch = record.brand.toLowerCase().contains(query);
          final itemMatch = record.itemDescription.toLowerCase().contains(query);
          return referenceMatch || brandMatch || itemMatch;
        }).toList();
      } else {
        _displayRecords = List.from(_allRecords);
      }
      _startIndex = 0; 
      
      _selectedEntries.removeWhere((entry) => !_displayRecords.contains(entry));
      _selectedEntryForEdit = _selectedEntries.isNotEmpty ? _selectedEntries.first : null;
      _selectAll = _selectedEntries.length == _displayRecords.length && _displayRecords.isNotEmpty;
    });
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayRecords = List.from(_allRecords);
      _startIndex = 0;
      _selectedEntries.clear();
      _selectedEntryForEdit = null;
      _selectAll = false;
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return; 
    setState(() {
      if (_startIndex + _rowsPerPage < _displayRecords.length) {
        _startIndex += _rowsPerPage;
      }
    });
  }

  void prevPage() {
    if (_rowsPerPage == _showAllValue) return; 
    setState(() {
      if (_startIndex - _rowsPerPage >= 0) {
        _startIndex -= _rowsPerPage;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _selectedEntries.clear();
        _selectAll = false;
        _selectedEntryForEdit = null;
      } else {
        _selectedEntries = Set.from(_displayRecords);
        _selectAll = true;
        _selectedEntryForEdit = _selectedEntries.isNotEmpty ? _selectedEntries.first : null;
      }
    });
  }

  void _toggleEntrySelection(TransactionEntry entry) {
    setState(() {
      if (_selectedEntries.contains(entry)) {
        _selectedEntries.remove(entry);
        if (_selectedEntryForEdit == entry) {
          _selectedEntryForEdit = _selectedEntries.isNotEmpty ? _selectedEntries.first : null;
        }
      } else {
        _selectedEntries.add(entry);
        _selectedEntryForEdit = entry;
      }
      
      _selectAll = _selectedEntries.length == _displayRecords.length && _displayRecords.isNotEmpty;
    });
  }

  void _changeRowsPerPage(int newRowsPerPage) {
    if (newRowsPerPage > 1000 || newRowsPerPage == _showAllValue) {
      final int totalEntries = newRowsPerPage == _showAllValue ? _displayRecords.length : newRowsPerPage;
      if (totalEntries > 1000) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Performance Warning'),
              content: Text(
                'You are about to display ${newRowsPerPage == _showAllValue ? "all ${_displayRecords.length}" : totalEntries} entries at once. '
                'This may impact performance and make the page slower to load. '
                'Are you sure you want to continue?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _rowsPerPage = newRowsPerPage;
                      _startIndex = 0; 
                      _selectAll = _selectedEntries.length == _displayRecords.length && _displayRecords.isNotEmpty;
                    });
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
        return;
      }
    }
    
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0; 
      _selectAll = _selectedEntries.length == _displayRecords.length && _displayRecords.isNotEmpty;
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
    _referenceError = null;
    _referenceExists = false;
    _isValidatingReference = false;
    _selectedStockLocation = null; 

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
                        onChanged: (value) => _validateReference(value),
                        decoration: InputDecoration(
                          labelText: 'DR/SI Reference',
                          hintText: 'Enter reference number',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.edit),
                          suffixIcon: _buildReferenceValidationIcon(),
                          errorText: _referenceError,
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
          _selectedEntries.clear();
          _selectedEntryForEdit = null; 
          _selectAll = false;
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

  void _showDeleteConfirmationDialog(String referenceId) {
    final selectedCount = _selectedEntries.length;
    final message = selectedCount > 1 
        ? 'Are you sure you want to delete $selectedCount selected transaction entries? This action cannot be undone.'
        : 'Are you sure you want to delete the transaction entry with Reference: $referenceId? This action cannot be undone.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                if (selectedCount > 1) {
                  _deleteMultipleEntries();
                } else {
                  _deleteEntry(referenceId);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMultipleEntries() async {
    final entriesToDelete = List.from(_selectedEntries);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Deleting...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while the entries are being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      int successCount = 0;
      List<String> errors = [];

      for (TransactionEntry entry in entriesToDelete) {
        try {
          final response = await _service.deleteTransactionEntry(entry.reference);
          if (response.statusCode == 200 || response.statusCode == 204) {
            successCount++;
          } else {
            errors.add('Failed to delete ${entry.reference}: ${response.statusCode}');
          }
        } catch (e) {
          errors.add('Error deleting ${entry.reference}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchRecords();
      setState(() {
        _selectedEntries.clear();
        _selectedEntryForEdit = null;
        _selectAll = false;
      });

      if (!mounted) return;

      String message;
      if (errors.isEmpty) {
        message = 'Successfully deleted $successCount entries!';
      } else {
        message = 'Deleted $successCount entries successfully.\n\nErrors:\n${errors.join('\n')}';
      }

      _showDialog(errors.isEmpty ? 'Success' : 'Partial Success', message);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showDialog('Error', 'An error occurred during deletion: $e');
    }
  }

  Future<void> _deleteEntry(String referenceId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Deleting...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while the entry is being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.deleteTransactionEntry(referenceId);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchRecords(); 
        setState(() {
          _selectedEntries.clear();
          _selectedEntryForEdit = null; 
          _selectAll = false;
        });
        if (!mounted) return;
        _showDialog('Success', 'Transaction entry successfully deleted!');
      } else {
        if (!mounted) return;
        _showDialog('Error', 'Failed to delete entry. Server responded with ${response.statusCode}: ${response.body}.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred during deletion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayRecords.length : _rowsPerPage;
    final endIndex = showAll 
        ? _displayRecords.length
        : (_startIndex + effectiveRowsPerPage > _displayRecords.length)
            ? _displayRecords.length
            : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Recording',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _resetToFullList,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset List',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Assets/Images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            double horizontalPadding = 16.0;
            
            if (screenWidth > 1400) {
              horizontalPadding = 32.0;
            } else if (screenWidth > 1000) {
              horizontalPadding = 24.0;
            } else if (screenWidth < 600) {
              horizontalPadding = 8.0;
            }
            
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 800;
                    final isMediumScreen = constraints.maxWidth < 1200;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: 16.0, 
                        left: isSmallScreen ? 16 : (isMediumScreen ? 50 : 100),
                        right: isSmallScreen ? 16 : (isMediumScreen ? 50 : 100),
                      ),
                      child: isSmallScreen
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      depth: -4,
                                      color: Colors.white,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, color: Color(0xFF01579B)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: const InputDecoration(
                                              hintText: 'Search...',
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        if (_searchController.text.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              _searchController.clear();
                                            },
                                            child: const Icon(Icons.clear, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildResponsiveButton(
                                      'Add',
                                      Icons.add,
                                      _showAddEntryDialog,
                                      isHovered: _isHovered,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      _selectAll ? 'Deselect' : 'Select All',
                                      _selectAll ? Icons.deselect : Icons.select_all,
                                      _toggleSelectAll,
                                      isPressed: _selectAll,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      'Edit',
                                      Icons.edit,
                                      _selectedEntryForEdit == null 
                                          ? null 
                                          : () => _showEditEntryDialog(_selectedEntryForEdit!),
                                      isEnabled: _selectedEntryForEdit != null,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      'Delete',
                                      Icons.delete,
                                      _selectedEntries.isEmpty
                                          ? null
                                          : () => _showDeleteConfirmationDialog(_selectedEntries.first.reference),
                                      isEnabled: _selectedEntries.isNotEmpty,
                                      isDelete: true,
                                      isSmall: true,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: SizedBox(
                                      height: 40,
                                      child: Neumorphic(
                                        style: NeumorphicStyle(
                                          depth: -4,
                                          color: Colors.white,
                                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.search, color: Color(0xFF01579B)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextField(
                                                controller: _searchController,
                                                decoration: InputDecoration(
                                                  hintText: isMediumScreen 
                                                      ? 'Search...' 
                                                      : 'Search by Reference, Brand, or Item',
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                ),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ),
                                            if (_searchController.text.isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  _searchController.clear();
                                                },
                                                child: const Icon(Icons.clear, color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                MouseRegion(
                                  onEnter: (_) => setState(() => _isHovered = true),
                                  onExit: (_) => setState(() => _isHovered = false),
                                  child: NeumorphicButton(
                                    onPressed: _showAddEntryDialog,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _isHovered ? -4 : 4,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      isMediumScreen ? 'Add' : 'Add Entry',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF01579B),
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _toggleSelectAll,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectAll ? -4 : 4,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectAll ? Colors.blue[100] : Colors.white,
                                    ),
                                    child: Text(
                                      _selectAll 
                                          ? (isMediumScreen ? 'Deselect' : 'Deselect All')
                                          : (isMediumScreen ? 'Select' : 'Select All'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectAll ? const Color(0xFF01579B) : const Color(0xFF01579B),
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedEntryForEdit == null 
                                        ? null 
                                        : () {
                                            _showEditEntryDialog(_selectedEntryForEdit!);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedEntryForEdit != null ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedEntryForEdit != null ? Colors.white : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Edit'
                                          : (_selectedEntries.length > 1 ? 'Edit First Selected' : 'Edit Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedEntryForEdit != null ? const Color(0xFF01579B) : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedEntries.isEmpty
                                        ? null
                                        : () {
                                            _showDeleteConfirmationDialog(_selectedEntries.first.reference);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedEntries.isNotEmpty ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedEntries.isNotEmpty ? const Color.fromARGB(255, 175, 54, 46) : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Delete'
                                          : (_selectedEntries.length > 1 ? 'Delete Selected (${_selectedEntries.length})' : 'Delete Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedEntries.isNotEmpty ? Colors.white : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: -5,
                          intensity: 0.7,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                          lightSource: LightSource.topLeft,
                          shadowDarkColorEmboss: const Color.fromARGB(197, 93, 126, 153),
                          color: Colors.blue[400],
                        ),
                        child: _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dataTableTheme: DataTableThemeData(
                                        checkboxHorizontalMargin: 0.0,
                                        columnSpacing: constraints.maxWidth > 1200 ? 12.0 : 6.0,
                                        horizontalMargin: constraints.maxWidth > 800 ? 4.0 : 2.0,
                                      ),
                                      checkboxTheme: CheckboxThemeData(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: DataTable(
                                      columnSpacing: constraints.maxWidth > 1200 ? 12.0 : 6.0,
                                      horizontalMargin: constraints.maxWidth > 800 ? 4.0 : 2.0,
                                      checkboxHorizontalMargin: 0.0,
                                      dataRowMaxHeight: 48.0,
                                      dataRowMinHeight: 40.0,
                                      headingRowHeight: constraints.maxWidth > 600 ? 52.0 : 44.0,
                                    columns: <DataColumn>[
                                      const DataColumn(
                                        label: Text(
                                          'DR/SI Reference',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Transaction Date' : 'Trans. Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Brand',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Item Description' : 'Item Desc.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Lot Number' : 'Lot No.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Expiry',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Quantity',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Stock Location' : 'Location',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: _displayRecords.isEmpty
                                        ? [
                                            const DataRow(cells: [
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('No results found', style: TextStyle(color: Colors.white))),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                            ])
                                          ]
                                        : _buildDataRows(formatter, endIndex, constraints.maxWidth),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (!_isLoading) 
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      
                      return Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: isSmallScreen ? 8 : 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            isSmallScreen ? 'Per page:' : 'Entries per page:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          Container(
                            height: isSmallScreen ? 30 : 35,
                            child: NeumorphicButton(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 12, 
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              style: NeumorphicStyle(
                                depth: 2,
                                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _rowsPerPage,
                                  items: [
                                    ..._rowsPerPageOptions.map((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      );
                                    }),
                                    DropdownMenuItem<int>(
                                      value: _showAllValue,
                                      child: Text(isSmallScreen ? 'All' : 'Show All'),
                                    ),
                                  ],
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      _changeRowsPerPage(newValue);
                                    }
                                  },
                                  style: TextStyle(
                                    color: Color(0xFF01579B),
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: const Color(0xFF01579B),
                                ),
                              ),
                            ),
                          ),
                          _buildPaginationControls(endIndex),
                        ],
                      );
                    },
                  ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<DataRow> _buildDataRows(DateFormat formatter, int endIndex, double screenWidth) {
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll 
        ? _displayRecords 
        : _displayRecords.sublist(_startIndex, endIndex);

    double getColumnWidth(double baseWidth, double factor) {
      if (screenWidth > 1400) return baseWidth * 1.2;
      if (screenWidth > 1200) return baseWidth;
      if (screenWidth > 800) return baseWidth * 0.8;
      if (screenWidth > 600) return baseWidth * 0.7;
      return baseWidth * 0.6;
    }

    final referenceWidth = getColumnWidth(100, 1.0);
    final dateWidth = getColumnWidth(90, 1.0);
    final brandWidth = getColumnWidth(85, 1.0);
    final itemWidth = getColumnWidth(120, 1.5);
    final lotWidth = getColumnWidth(80, 1.0);
    final expiryWidth = getColumnWidth(90, 1.0);
    final quantityWidth = getColumnWidth(60, 0.8);
    final locationWidth = getColumnWidth(100, 1.2);

    return recordsToShow.map<DataRow>((data) {
      final isSelected = _selectedEntries.contains(data);
      final subtleBlueTint1 = const Color.fromRGBO(241, 245, 255, 1);
      final subtleBlueTint2 = const Color.fromRGBO(230, 240, 255, 1);
      final rowColor = counter.isEven ? subtleBlueTint1 : subtleBlueTint2;
      counter++;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) {
          _toggleEntrySelection(data);
        },
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(SizedBox(
            width: referenceWidth,
            child: Text(
              data.reference,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: screenWidth > 800 ? 2 : 1,
            ),
          )),
          DataCell(SizedBox(
            width: dateWidth,
            child: Text(
              formatter.format(data.transactionDate),
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(SizedBox(
            width: brandWidth,
            child: Text(
              data.brand,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(SizedBox(
            width: itemWidth,
            child: Text(
              data.itemDescription,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: screenWidth > 1000 ? 3 : (screenWidth > 600 ? 2 : 1),
            ),
          )),
          DataCell(SizedBox(
            width: lotWidth,
            child: Text(
              data.lotNumber,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(SizedBox(
            width: expiryWidth,
            child: Text(
              formatter.format(data.expiryDate),
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(SizedBox(
            width: quantityWidth,
            child: Text(
              data.quantity.toString(),
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )),
          DataCell(SizedBox(
            width: locationWidth,
            child: Text(
              data.stockLocation,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: screenWidth > 800 ? 2 : 1,
            ),
          )),
        ],
      );
    }).toList();
  }

  Widget _buildPaginationControls(int endIndex) {
    final bool showAll = _rowsPerPage == _showAllValue;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NeumorphicNavButton(
          icon: Icons.chevron_left,
          enabled: !showAll && _startIndex > 0,
          onPressed: prevPage,
          tooltip: 'Previous Page',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            showAll 
                ? 'Showing all ${_displayRecords.length} entries'
                : '${_displayRecords.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayRecords.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _NeumorphicNavButton(
          icon: Icons.chevron_right,
          enabled: !showAll && endIndex < _displayRecords.length,
          onPressed: nextPage,
          tooltip: 'Next Page',
        ),
      ],
    );
  }

  Widget _buildResponsiveButton(
    String label,
    IconData icon,
    VoidCallback? onPressed, {
    bool isEnabled = true,
    bool isPressed = false,
    bool isHovered = false,
    bool isDelete = false,
    bool isSmall = false,
  }) {
    return MouseRegion(
      child: NeumorphicButton(
        onPressed: isEnabled ? onPressed : null,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 8,
        ),
        style: NeumorphicStyle(
          depth: isEnabled ? (isPressed ? -2 : 2) : 1,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(isSmall ? 20 : 25),
          ),
          lightSource: LightSource.topLeft,
          color: isDelete && isEnabled
              ? const Color.fromARGB(255, 175, 54, 46)
              : isPressed && isEnabled
                  ? Colors.blue[100]
                  : isEnabled
                      ? Colors.white
                      : Colors.grey[300],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmall ? 16 : 18,
              color: isDelete && isEnabled
                  ? Colors.white
                  : isEnabled
                      ? const Color(0xFF01579B)
                      : Colors.grey[600],
            ),
            if (label.isNotEmpty) ...[
              SizedBox(width: isSmall ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDelete && isEnabled
                      ? Colors.white
                      : isEnabled
                          ? const Color(0xFF01579B)
                          : Colors.grey[600],
                  fontSize: isSmall ? 12 : 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceValidationIcon() {
    if (_isValidatingReference) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_referenceExists) {
      return Icon(
        Icons.warning,
        color: Colors.orange[600],
        size: 20,
      );
    }

    return const SizedBox.shrink();
  }
}
