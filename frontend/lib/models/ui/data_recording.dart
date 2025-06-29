import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordingData {
  final String reference;
  final DateTime transactionDate;
  final String brand;
  final String itemDescription;
  final int lotNumber;
  final DateTime expiryDate;
  final int quantity;
  final String stockLocation;

  RecordingData({
    required this.reference,
    required this.transactionDate,
    required this.brand,
    required this.itemDescription,
    required this.lotNumber,
    required this.expiryDate,
    required this.quantity,
    required this.stockLocation,
  });
}

class DataRecording extends StatefulWidget {
  const DataRecording({super.key});

  @override
  State<DataRecording> createState() => _DataRecordingState();
}

class _DataRecordingState extends State<DataRecording> {
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _itemSearchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  DateTime? _selectedTransactionDate;
  DateTime? _automaticExpiryDate;
  String? _selectedBrand;
  String? _selectedItemDescription;
  int? _selectedLotNumber;
  String? _selectedStockLocation;
  bool _dontAskAgain = false;

  final List<String> _brands = ['BioTech', 'BrandX', 'LabCorp', 'MediSupply', 'ChemTech'];
  final List<String> _stockLocations = [
    'Warehouse A, Shelf 1',
    'Warehouse A, Shelf 2', 
    'Warehouse A, Shelf 3',
    'Warehouse B, Shelf 1',
    'Cold Storage A',
    'Cold Storage B'
  ];
  
  final Map<String, List<int>> _lotNumbers = {
    'BioTech': [1001, 1002, 1003, 1004],
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

  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _itemSearchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  List<RecordingData> get sampledata {
    return [
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inchLaptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'asdawdasfwagasdwasdwasdwasdwasdwadswasdwasdwasdwasdwasdwad',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Wasdweagasfniawkamsohfgwiajsndohwabgis',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
      RecordingData(
        reference: 'DR12345',
        transactionDate: DateTime(2023, 10, 26),
        brand: 'BrandX',
        itemDescription: 'Laptop Pro 15-inch',
        lotNumber: 1001,
        expiryDate: DateTime(2025, 12, 31),
        quantity: 5,
        stockLocation: 'Warehouse A, Shelf 3',
      ),
    ];
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _calculateExpiryDate() {
    if (_selectedBrand != null && _selectedItemDescription != null) {
      setState(() {
        _automaticExpiryDate = DateTime.now().add(const Duration(days: 730));
      });
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
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTransactionDate = picked;
                            });
                            this.setState(() {
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
                          this.setState(() {
                            _selectedBrand = newValue;
                            _selectedLotNumber = null;
                          });
                          _calculateExpiryDate();
                        },
                      ),
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _itemSearchController,
                            decoration: const InputDecoration(
                              labelText: 'Item Description',
                              hintText: 'Search items by keywords',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              _filterItems(value);
                              setState(() {});
                            },
                          ),
                          if (_itemSearchController.text.isNotEmpty && _filteredItems.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 150),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(_filteredItems[index]),
                                      onTap: () {
                                        setState(() {
                                          _selectedItemDescription = _filteredItems[index];
                                          _itemSearchController.text = _filteredItems[index];
                                          _filteredItems = [];
                                        });
                                        this.setState(() {
                                          _selectedItemDescription = _filteredItems[index];
                                        });
                                        _calculateExpiryDate();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
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
                        onChanged: _selectedBrand != null
                            ? (int? newValue) {
                                setState(() {
                                  _selectedLotNumber = newValue;
                                });
                                this.setState(() {
                                  _selectedLotNumber = newValue;
                                });
                                _calculateExpiryDate();
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),

                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.autorenew),
                        ),
                        child: Text(
                          _automaticExpiryDate != null
                              ? 'Auto: ${DateFormat('yyyy-MM-dd').format(_automaticExpiryDate!)}'
                              : 'Will be calculated automatically',
                          style: TextStyle(
                            color: _automaticExpiryDate != null ? Colors.green : Colors.grey,
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
                          prefixIcon: Icon(Icons.arrow_drop_down),
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
                          this.setState(() {
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
    if (_selectedLotNumber == null) {
      errors.add('Lot Number is required');
    }
    if (_automaticExpiryDate == null) {
      errors.add('Expiry Date could not be calculated');
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
      _submitData();
    }
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
                  Text('Transaction Date: ${DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!)}'),
                  Text('Brand: $_selectedBrand'),
                  Text('Item: $_selectedItemDescription'),
                  Text('Lot Number: $_selectedLotNumber'),
                  Text('Expiry Date: ${DateFormat('yyyy-MM-dd').format(_automaticExpiryDate!)}'),
                  Text('Quantity: ${_quantityController.text}'),
                  Text('Stock Location: $_selectedStockLocation'),
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

  void _submitData() {
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Transaction data has been successfully submitted!'),
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
                onPressed: _showAddEntryDialog,
                child: const Text('Add Entry'),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.blueGrey,
                      width: 1,
                    ),
                    columnSpacing: 24.0,
                    horizontalMargin: 12.0,
                    dataRowMinHeight: 48.0,
                    dataRowMaxHeight: 100.0,
                    headingRowHeight: 56.0,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'DR/SI Reference',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Transaction Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Brand',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Item Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Lot Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Expiry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Stock Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: sampledata.map<DataRow>((data) {
                      return DataRow(
                        cells: [
                          DataCell(SizedBox(width: 100, child: Text(data.reference, softWrap: true))),
                          DataCell(SizedBox(width: 90, child: Text(formatter.format(data.transactionDate), softWrap: true))),
                          DataCell(SizedBox(width: 85, child: Text(data.brand, softWrap: true))),
                          DataCell(SizedBox(width: 200, child: Text(data.itemDescription, softWrap: true))),
                          DataCell(SizedBox(width: 70, child: Text(data.lotNumber.toString(), softWrap: true))),
                          DataCell(SizedBox(width: 90, child: Text(formatter.format(data.expiryDate), softWrap: true))),
                          DataCell(SizedBox(width: 45, child: Text(data.quantity.toString(), softWrap: true))),
                          DataCell(SizedBox(width: 190, child: Text(data.stockLocation, softWrap: true))),
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
