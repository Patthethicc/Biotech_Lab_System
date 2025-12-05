import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'package:frontend/services/transaction_entry_service.dart';
import 'package:frontend/services/inventory_service.dart';
import 'package:frontend/services/customer_service.dart';
import 'package:frontend/models/api/customer_model.dart';
import 'package:frontend/models/api/inventory.dart';
import 'dart:convert'; 

class TransactionEntryPage extends StatefulWidget {
  const TransactionEntryPage({super.key});
  @override
  State<TransactionEntryPage> createState() => _TransactionEntryPageState();
}

class _TransactionEntryPageState extends State<TransactionEntryPage> {
  final TransactionEntryService _service = TransactionEntryService();
  final BrandService _brandService = BrandService();
  final InventoryService _inventoryService = InventoryService();
  final CustomerService _customerService = CustomerService();

  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _lotNumberController = TextEditingController();
  
  // Customer Controller (UI only)
  final TextEditingController _customerController = TextEditingController();

  List<TransactionEntry> _records = [];
  List<TransactionEntry> _displayRecords = [];
  List<BrandModel> _brands = [];
  List<Customer> _customers = [];
  List<String> _productDescriptions = []; // For the dropdown
  
  bool _isLoading = true;

  DateTime? _selectedTransactionDate;
  DateTime? _selectedExpiryDate;
  BrandModel? _selectedBrand;
  Customer? _selectedCustomer;
  String? _selectedStockLocation;
  String? _selectedItemDescription; // For the dropdown
  
  String? _selectedItemCode; // To store the item code

  // File selections
  String? selectedPoFileName;
  Uint8List? selectedPoFileBytes;
  String? selectedPackingListFileName;
  Uint8List? selectedPackingListFileBytes;
  String? selectedInventoryName;
  Uint8List? selectedInventoryBytes;

  final List<String> _stockLocations = [
    'Lazcano (Ref 1)',
    'Lazcano (Ref 2)',
    'Gandia (Cold Storage)',
    'Gandia (Ref 1)',
    'Gandia (Ref 2)',
    'Limbaga',
    'Cebu'
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
    _loadBrands();
    _loadCustomers();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _lotNumberController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _brandService.getBrands();
      setState(() {
        _brands = brands;
      });
    } catch (e) {
      debugPrint('Error loading brands: $e');
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _customerService.getCustomers();
      setState(() {
        _customers = customers;
      });
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
  }

  Future<void> _loadProductDescriptions(String brandName) async {
    try {
      final descriptions = await _inventoryService.getProductDescriptions(brandName);
      setState(() {
        _productDescriptions = descriptions;
        _selectedItemDescription = null; // Reset selection
        _selectedItemCode = null; // Reset item code
      });
    } catch (e) {
      debugPrint('Error loading descriptions: $e');
    }
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _service.fetchTransactionEntries();
      setState(() {
        _records = entries..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _displayRecords = List.from(_records);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showDialog('Error', 'Failed to load transaction data: $e');
    }
  }

  // Auto-fill logic
  Future<void> _onItemDescriptionChanged(String? description) async {
    if (_selectedBrand == null || description == null) return;
    
    setState(() {
      _selectedItemDescription = description;
    });

    try {
      Inventory? inventory = await _inventoryService.searchInventory(_selectedBrand!.brandName, description);
      if (inventory != null) {
        setState(() {
          _selectedItemCode = inventory.itemCode; // Capture item code
          _lotNumberController.text = inventory.lotNum?.toString() ?? '';
          if (inventory.expiry.isNotEmpty) {
            _selectedExpiryDate = DateTime.tryParse(inventory.expiry);
          }
          _costController.text = inventory.costOfSale?.toString() ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item details auto-filled!')),
        );
      }
    } catch (e) {
      debugPrint('Error searching inventory: $e');
    }
  }

  void _showLocationDialog(StateSetter setStateDialog) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location & Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStockLocation,
              decoration: const InputDecoration(labelText: 'Stock Location', border: OutlineInputBorder()),
              items: _stockLocations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) {
                 // We need to update the parent dialog state as well if we want it to reflect immediately, 
                 // but here we are in a nested dialog. We'll update the main state variables.
                 _selectedStockLocation = val;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Just close, the values are in the controllers/variables
              setStateDialog(() {}); // Trigger rebuild of parent dialog to show selected values
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitData() async {
    // Validation
    if (_referenceController.text.isEmpty ||
        _selectedTransactionDate == null ||
        _selectedBrand == null ||
        _selectedItemDescription == null ||
        _lotNumberController.text.isEmpty ||
        _selectedExpiryDate == null ||
        _quantityController.text.isEmpty ||
        _costController.text.isEmpty ||
        _selectedStockLocation == null) {
      _showDialog('Error', 'Please fill in all required fields.');
      return;
    }

    // Confirmation
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Please double check the data. Are you sure you want to submit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    final newEntry = {
      "drSIReferenceNum": _referenceController.text,
      "transactionDate": _selectedTransactionDate!.toIso8601String(),
      "brand": _selectedBrand?.brandName,
      "productDescription": _selectedItemDescription,
      "itemCode": _selectedItemCode, // Include item code
      "lotSerialNumber": _lotNumberController.text,
      "expiryDate": _selectedExpiryDate!.toIso8601String(),
      "cost": double.tryParse(_costController.text) ?? 0.0,
      "quantity": int.tryParse(_quantityController.text) ?? 0,
      "stockLocation": _selectedStockLocation,
      // Optional files
      "purchaseOrderFileName": selectedPoFileName,
      "suppliersPackingListName": selectedPackingListFileName,
      "inventoryOfDeliveredItemsName": selectedInventoryName,
      "purchaseOrderFile": selectedPoFileBytes != null ? base64Encode(selectedPoFileBytes!) : null,
      "suppliersPackingList": selectedPackingListFileBytes != null ? base64Encode(selectedPackingListFileBytes!) : null,
      "inventoryOfDeliveredItems": selectedInventoryBytes != null ? base64Encode(selectedInventoryBytes!) : null
    };

    try {
      final response = await _service.submitTransactionEntry(newEntry);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context); // Close add dialog
          _showDialog('Success', 'Transaction recorded successfully!');
          _fetchRecords();
        }
      } else {
        if (mounted) _showDialog('Error', 'Failed to submit: ${response.body}');
      }
    } catch (e) {
      if (mounted) _showDialog('Error', 'An error occurred: $e');
    }
  }

  void _showAddEntryDialog() {
    // Reset fields
    _referenceController.clear();
    _quantityController.clear();
    _costController.clear();
    _lotNumberController.clear();
    _customerController.clear();
    _selectedTransactionDate = null;
    _selectedExpiryDate = null;
    _selectedBrand = null;
    _selectedCustomer = null;
    _selectedStockLocation = null;
    _selectedItemDescription = null;
    _selectedItemCode = null; // Reset item code
    _productDescriptions = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Transaction Entry'),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reference
                      TextField(
                        controller: _referenceController,
                        decoration: const InputDecoration(labelText: 'DR/SI Reference', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      
                      // Transaction Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setStateDialog(() => _selectedTransactionDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Transaction Date', border: OutlineInputBorder()),
                          child: Text(_selectedTransactionDate != null ? DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!) : 'Select Date'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand Popup
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Brand'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _brands.length,
                                  itemBuilder: (context, index) {
                                    final brand = _brands[index];
                                    return ListTile(
                                      title: Text(brand.brandName),
                                      onTap: () async {
                                        setStateDialog(() {
                                          _selectedBrand = brand;
                                          _selectedItemDescription = null; // Reset item description
                                        });
                                        // Load descriptions for the selected brand
                                        await _loadProductDescriptions(brand.brandName);
                                        setStateDialog(() {}); // Rebuild to show dropdown items
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder()),
                          child: Text(_selectedBrand?.brandName ?? 'Select Brand'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Item Description Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedItemDescription,
                        decoration: const InputDecoration(labelText: 'Item Description', border: OutlineInputBorder()),
                        items: _productDescriptions.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: _selectedBrand == null ? null : (val) {
                          _onItemDescriptionChanged(val);
                          setStateDialog(() {});
                        },
                        hint: const Text('Select Item Description'),
                        isExpanded: true,
                      ),
                      const SizedBox(height: 16),

                      // Auto-filled fields
                      TextField(
                        controller: _lotNumberController,
                        decoration: const InputDecoration(labelText: 'Lot Number', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setStateDialog(() => _selectedExpiryDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Expiry Date', border: OutlineInputBorder()),
                          child: Text(_selectedExpiryDate != null ? DateFormat('yyyy-MM-dd').format(_selectedExpiryDate!) : 'Select Date'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Unit SRP', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),

                      // Customer Popup
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Customer'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _customers.length,
                                  itemBuilder: (context, index) {
                                    final customer = _customers[index];
                                    return ListTile(
                                      title: Text(customer.name),
                                      subtitle: Text(customer.address ?? ''),
                                      onTap: () {
                                        setStateDialog(() {
                                          _selectedCustomer = customer;
                                          _customerController.text = customer.name;
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Customer', border: OutlineInputBorder()),
                          child: Text(_selectedCustomer?.name ?? 'Select Customer'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location & Quantity Popup Trigger
                      InkWell(
                        onTap: () {
                          _showLocationDialog(setStateDialog);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Location & Quantity', border: OutlineInputBorder()),
                          child: Text(
                            (_selectedStockLocation != null && _quantityController.text.isNotEmpty)
                                ? '$_selectedStockLocation - ${_quantityController.text} pcs'
                                : 'Select Location & Quantity'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(onPressed: _submitData, child: const Text('Submit')),
              ],
            );
          },
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Entry')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddEntryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Ref No.')),
                        DataColumn(label: Text('Brand')),
                        DataColumn(label: Text('Item Description')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Location')),
                      ],
                      rows: _displayRecords.map((entry) {
                        return DataRow(cells: [
                          DataCell(Text(DateFormat('yyyy-MM-dd').format(entry.transactionDate))),
                          DataCell(Text(entry.reference)),
                          DataCell(Text(entry.brand)),
                          DataCell(Text(entry.itemDescription)),
                          DataCell(Text(entry.quantity.toString())),
                          DataCell(Text(entry.stockLocation)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}