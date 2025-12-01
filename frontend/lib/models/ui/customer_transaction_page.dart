import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/brand_model.dart';
import 'package:frontend/models/api/customer_model.dart';
import 'package:frontend/models/api/customer_transaction_model.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:frontend/services/customer_service.dart';
import 'package:frontend/services/customer_transaction_service.dart';
import 'package:intl/intl.dart';
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
class CartItem {
  String itemId;
  String brandName;
  String itemDescription;
  String lotNumber;
  double unitRetailPrice;
  int quantity;
  String location;

  CartItem({
    required this.itemId,
    required this.brandName,
    required this.itemDescription,
    required this.lotNumber,
    required this.unitRetailPrice,
    required this.quantity,
    required this.location,
  });
}
class CustomerTransactionPage extends StatefulWidget {
  const CustomerTransactionPage({super.key});
  @override
  State<CustomerTransactionPage> createState() =>
      _CustomerTransactionPageState();
}

class _CustomerTransactionPageState extends State<CustomerTransactionPage> {
  final CustomerTransactionService _service = CustomerTransactionService();
  final CustomerService _customerService = CustomerService();
  final BrandService _brandService = BrandService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _invoiceRefController = TextEditingController();

  List<CustomerTransaction> _transactions = [];
  List<CustomerTransaction> _allTransactions = [];
  List<CustomerTransaction> _displayTransactions = [];
  bool _isLoading = true;
  bool _isHovered = false;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100];
  final int _showAllValue = -1;

  bool _dontAskAgain = false;
  CustomerTransaction? _selectedTransactionForEdit;
  Set<CustomerTransaction> _selectedTransactions = {};
  bool _selectAll = false;
  
  DateTime? _selectedTransactionDate;
  Customer? _selectedCustomer;
  final List<CartItem> _itemsInCart = [];


  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTransactions);
    _searchController.dispose();
    _invoiceRefController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _service.getCustomerTransactions();
      setState(() {
        _transactions = transactions
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _allTransactions = List.from(_transactions);
        _displayTransactions = List.from(_allTransactions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Error', 'Failed to load transactions: $e');
      }
    }
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayTransactions = _allTransactions.where((tx) {
          final refMatch = tx.invoiceReference.toLowerCase().contains(query);
          final customerMatch = tx.customerName.toLowerCase().contains(query);
          return refMatch || customerMatch;
        }).toList();
      } else {
        _displayTransactions = List.from(_allTransactions);
      }
      _startIndex = 0;
      
      _selectedTransactions.removeWhere((tx) => !_displayTransactions.contains(tx));
      _selectedTransactionForEdit = _selectedTransactions.isNotEmpty ? _selectedTransactions.first : null;
      _selectAll = _selectedTransactions.length == _displayTransactions.length && _displayTransactions.isNotEmpty;
    });
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayTransactions = List.from(_allTransactions);
      _startIndex = 0;
      _selectedTransactions.clear();
      _selectedTransactionForEdit = null;
      _selectAll = false;
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return;
    setState(() {
      if (_startIndex + _rowsPerPage < _displayTransactions.length) {
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
  
  void _changeRowsPerPage(int newRowsPerPage) {
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0; 
      _selectAll = _selectedTransactions.length == _displayTransactions.length && _displayTransactions.isNotEmpty;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAll) {
        _selectedTransactions.clear();
        _selectAll = false;
        _selectedTransactionForEdit = null;
      } else {
        _selectedTransactions = Set.from(_displayTransactions);
        _selectAll = true;
        _selectedTransactionForEdit = _selectedTransactions.isNotEmpty ? _selectedTransactions.first : null;
      }
    });
  }

  void _toggleEntrySelection(CustomerTransaction tx) {
    setState(() {
      if (_selectedTransactions.contains(tx)) {
        _selectedTransactions.remove(tx);
        if (_selectedTransactionForEdit == tx) {
          _selectedTransactionForEdit = _selectedTransactions.isNotEmpty ? _selectedTransactions.first : null;
        }
      } else {
        _selectedTransactions.add(tx);
        _selectedTransactionForEdit = tx;
      }
      
      _selectAll = _selectedTransactions.length == _displayTransactions.length && _displayTransactions.isNotEmpty;
    });
  }

  void _showAddTransactionDialog() {
    _invoiceRefController.clear();
    setState(() {
      _selectedTransactionDate = null;
      _selectedCustomer = null;
      _itemsInCart.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('New Customer Transaction'),
              content: SizedBox(
                width: 700,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _invoiceRefController,
                        decoration: const InputDecoration(
                          labelText: 'Invoice Reference',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
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
                            setStateDialog(() {
                              _selectedTransactionDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Transaction Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedTransactionDate != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(_selectedTransactionDate!)
                                : 'Select date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Customer'),
                        subtitle: Text(
                          _selectedCustomer?.name ?? 'No customer selected',
                        ),
                        leading: const Icon(Icons.person, color: Color(0xFF01579B), size: 36),
                        trailing: ElevatedButton(
                          child: Text(_selectedCustomer == null
                              ? 'Select'
                              : 'Change'),
                          onPressed: () async {
                            final Customer? chosenCustomer =
                                await _showCustomerSelectDialog();
                            if (chosenCustomer != null) {
                              setStateDialog(() {
                                _selectedCustomer = chosenCustomer;
                              });
                            }
                          },
                        ),
                      ),
                      const Divider(height: 24),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Items to Sell'),
                        leading:
                            const Icon(Icons.shopping_cart, color: Color(0xFF01579B), size: 36),
                        trailing: ElevatedButton(
                          child: const Text('Add Item'),
                          onPressed: () async {
                            final CartItem? newItem =
                                await _showBrandItemSelectDialog();
                            if (newItem != null) {
                              setStateDialog(() {
                                _itemsInCart.add(newItem);
                              });
                            }
                          },
                        ),
                      ),

                      _buildCartList(setStateDialog),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    List<String> errors = [];
                    if (_invoiceRefController.text.trim().isEmpty) {
                      errors.add('Invoice Reference is required');
                    }
                    if (_selectedTransactionDate == null) {
                      errors.add('Transaction Date is required');
                    }
                    if (_selectedCustomer == null) {
                      errors.add('Customer is required');
                    }
                    if (_itemsInCart.isEmpty) {
                      errors.add('At least one item must be added');
                    }

                    if (errors.isNotEmpty) {
                      _showErrorListDialog(errors);
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    _showConfirmationDialog();
                  },
                  child: const Text('Submit Transaction'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<Customer?> _showCustomerSelectDialog() async {
    List<Customer> allCustomers = [];
    bool isLoading = true;
    String searchTerm = "";

    return showDialog<Customer>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (isLoading && allCustomers.isEmpty) {
              _customerService.getCustomers().then((customers) {
                setStateDialog(() {
                  allCustomers = customers;
                  isLoading = false;
                });
              }).catchError((e) {
                Navigator.of(context).pop();
                _showErrorDialog('Error', 'Failed to load customers: $e');
              });
            }

            final filteredCustomers = allCustomers
                .where((c) =>
                    c.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
                    c.address.toLowerCase().contains(searchTerm.toLowerCase())
                    )
                .toList();

            return AlertDialog(
              title: const Text('Select Customer'),
              content: SizedBox(
                width: 500,
                height: 300,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'Search by name or address', prefixIcon: Icon(Icons.search)),
                      onChanged: (value) {
                        setStateDialog(() {
                          searchTerm = value;
                        });
                      },
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return ListTile(
                                  title: Text(customer.name),
                                  subtitle: Text(customer.address),
                                  onTap: () {
                                    Navigator.of(context).pop(customer);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<CartItem?> _showBrandItemSelectDialog() async {
    BrandModel? selectedBrand;
    Map<String, dynamic>? selectedItem;
    Map<String, dynamic>? itemDetails;

    List<BrandModel> allBrands = [];
    List<Map<String, dynamic>> itemsForBrand = [];
    
    Map<String, dynamic>? selectedLot;
    String? selectedLocation;
    int quantityToSell = 0;
    
    try {
      allBrands = await _brandService.getBrands();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to load brands: $e');
      }
      return null;
    }

    return showDialog<CartItem>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Item to Cart'),
              content: SizedBox(
                width: 600,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<BrandModel>(
                        value: selectedBrand,
                        decoration: const InputDecoration(
                            labelText: '1. Select Brand',
                            border: OutlineInputBorder()),
                        items: allBrands.map((BrandModel brand) {
                          return DropdownMenuItem<BrandModel>(
                            value: brand,
                            child: Text(brand.brandName),
                          );
                        }).toList(),
                        onChanged: (BrandModel? newValue) async {
                          if (newValue == null) return;
                          
                          setStateDialog(() {
                            selectedBrand = newValue;
                            selectedItem = null;
                            itemDetails = null;
                            itemsForBrand = [];
                            selectedLot = null;
                            selectedLocation = null;
                            quantityToSell = 0;
                          });
                          try {
                            final items = await _service
                                .getItemsForBrand(newValue.brandId.toString());
                            setStateDialog(() {
                              itemsForBrand = items;
                            });
                          } catch (e) {
                            if (mounted) {
                              _showErrorDialog(
                                  'Error', 'Failed to load items: $e');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedBrand != null)
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedItem,
                          decoration: const InputDecoration(
                              labelText: '2. Select Item',
                              border: OutlineInputBorder()),
                          items: itemsForBrand
                              .map((Map<String, dynamic> item) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: Text(item['itemDescription'] ?? 'N/A'),
                            );
                          }).toList(),
                          onChanged: (Map<String, dynamic>? newValue) async {
                            if (newValue == null) return;
                            setStateDialog(() {
                              selectedItem = newValue;
                              itemDetails = null;
                              selectedLot = null;
                              selectedLocation = null;
                              quantityToSell = 0;
                            });
                            try {
                              final details = await _service
                                  .getItemDetails(newValue['itemId']);
                              setStateDialog(() {
                                itemDetails = details;
                              });
                            } catch (e) {
                              if (mounted) {
                                _showErrorDialog(
                                    'Error', 'Failed to load item details: $e');
                              }
                            }
                          },
                        ),
                      const SizedBox(height: 16),

                      if (itemDetails != null) ...[
                        const Text('3. Select Lot, Location, and Quantity',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                                                DropdownButtonFormField<String>(
                          value: selectedLot?['lotNumber']?.toString(),
                          decoration: const InputDecoration(
                              labelText: 'Lot Number', border: OutlineInputBorder()),
                          items: (itemDetails!['lots'] as List? ?? [])
                              .map((lot) {
                                return DropdownMenuItem<String>(
                                  value: lot['lotNumber']?.toString(),
                                  child: Text(
                                      'Lot: ${lot['lotNumber']} (Expires: ${lot['expiryDate']})'),
                                );
                              })
                              .toList()
                              .cast<DropdownMenuItem<String>>(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              // Find the full lot object based on the selected string ID
                              selectedLot = (itemDetails!['lots'] as List?)?.firstWhere(
                                (lot) => lot['lotNumber']?.toString() == newValue,
                                orElse: () => null,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: selectedLocation,
                          decoration: const InputDecoration(
                              labelText: 'Deduct from Location',
                              border: OutlineInputBorder()),
                          items: (itemDetails!['locations'] as List? ?? [])
                              .map((loc) {
                                return DropdownMenuItem<String>(
                                  value: loc['locationName'],
                                  child: Text(
                                      '${loc['locationName']} (Stock: ${loc['availableStock']})'),
                                );
                              })
                              .toList()
                              .cast<DropdownMenuItem<String>>(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              selectedLocation = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity to Sell',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            quantityToSell = int.tryParse(value) ?? 0;
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                            'Unit SRP: \$${selectedLot?['unitRetailPrice']?.toStringAsFixed(2) ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    List<String> errors = [];
                    if (selectedBrand == null) errors.add('Brand is not selected.');
                    if (selectedItem == null) errors.add('Item is not selected.');
                    if (itemDetails == null) errors.add('Item details not loaded.');
                    if (selectedLot == null) errors.add('Lot number is not selected.');
                    if (selectedLocation == null) errors.add('Location is not selected.');
                    if (quantityToSell <= 0) errors.add('Quantity must be greater than 0.');

                    if (errors.isNotEmpty) {
                      _showErrorListDialog(errors);
                      return;
                    }

                    final locationData = (itemDetails!['locations'] as List)
                        .firstWhere((loc) => loc['locationName'] == selectedLocation);
                    if (quantityToSell > locationData['availableStock']) {
                       _showErrorDialog('Error',
                          'Quantity to sell ($quantityToSell) exceeds available stock (${locationData['availableStock']}) at $selectedLocation.');
                      return;
                    }

                    final cartItem = CartItem(
                      itemId: selectedItem!['itemId'],
                      brandName: selectedBrand!.brandName,
                      itemDescription: selectedItem!['itemDescription'],
                      lotNumber: selectedLot!['lotNumber'],
                      unitRetailPrice: selectedLot!['unitRetailPrice'],
                      quantity: quantityToSell,
                      location: selectedLocation!,
                    );

                    Navigator.of(context).pop(cartItem);
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog() {
    double total = _itemsInCart.fold(0.0, (sum, item) => sum + (item.unitRetailPrice * item.quantity));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Confirm Transaction'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('Please double-check the data before submitting:'),
                    const SizedBox(height: 16),
                    Text('Invoice Reference: ${_invoiceRefController.text}'),
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedTransactionDate!)}'),
                    Text('Customer: ${_selectedCustomer!.name}'),
                    const Divider(height: 24),
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._itemsInCart.map((item) => ListTile(
                          title: Text(item.itemDescription),
                          subtitle: Text(
                              '${item.quantity} x \$${item.unitRetailPrice.toStringAsFixed(2)} from ${item.location}'),
                          trailing: Text(
                              '\$${(item.quantity * item.unitRetailPrice).toStringAsFixed(2)}'),
                        )),
                    const Divider(height: 24),
                    Text('Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Do not ask me again'),
                      value: _dontAskAgain,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          _dontAskAgain = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    _submitTransaction();
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

  Future<void> _submitTransaction() async {
    final List<Sold> soldItems = _itemsInCart.map((cartItem) {
      return Sold(
        itemId: cartItem.itemId,
        lotNumber: cartItem.lotNumber,
        quantity: cartItem.quantity,
        unitRetailPrice: cartItem.unitRetailPrice,
        brandName: cartItem.brandName,
        itemDescription: cartItem.itemDescription,
        location: cartItem.location,
      );
    }).toList();

    double calculatedTotal = 0;
    for (var item in soldItems) {
      calculatedTotal += item.quantity * item.unitRetailPrice;
    }

    final newTransaction = CustomerTransaction(
      invoiceReference: _invoiceRefController.text.trim(),
      transactionDate: _selectedTransactionDate!,
      customerId: _selectedCustomer!.customerId,
      customerName: _selectedCustomer!.name,
      items: soldItems,
      totalRetailPrice: calculatedTotal,
    );

    _showLoadingDialog('Submitting Transaction...');

    try {
      final response =
          await _service.createCustomerTransaction(newTransaction);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog(
            'Success', 'Transaction created successfully! Stock has been updated.');
        _fetchTransactions();
      } else {
        _showErrorDialog('Error',
            'Failed to create transaction: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorDialog('Error', 'An error occurred: $e');
    }
  }

  void _showDeleteConfirmationDialog(CustomerTransaction tx) {
    final selectedCount = _selectedTransactions.length;
    final bool deletingMultiple = selectedCount > 1 && _selectedTransactions.contains(tx);
    
    final message = deletingMultiple
        ? 'Are you sure you want to delete $selectedCount selected transactions? This action cannot be undone.'
        : 'Are you sure you want to delete transaction ${tx.invoiceReference}? This will not re-add the stock (this must be done manually with an Inbound Transaction).';

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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); 
                if (deletingMultiple) {
                  _deleteMultipleEntries();
                } else {
                  _deleteEntry(tx);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEntry(CustomerTransaction tx) async {
    if (tx.transactionId == null) {
      _showErrorDialog('Error', 'Cannot delete transaction with a null ID.');
      return;
    }
    
    _showLoadingDialog('Deleting...');

    try {
      final response = await _service.deleteCustomerTransaction(tx.transactionId!);
      if (!mounted) return;
      Navigator.of(context).pop();
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessDialog('Deleted', 'Transaction deleted.');
        _fetchTransactions();
      } else {
        _showErrorDialog('Error', 'Failed to delete: ${response.body}');
      }
    } catch (e) {
       if (!mounted) return;
       Navigator.of(context).pop();
       _showErrorDialog('Error', 'An error occurred: $e');
    }
  }

  Future<void> _deleteMultipleEntries() async {
    final entriesToDelete = List.from(_selectedTransactions);
    
    _showLoadingDialog('Deleting ${entriesToDelete.length} entries...');

    try {
      int successCount = 0;
      List<String> errors = [];

      for (CustomerTransaction tx in entriesToDelete) {
        if (tx.transactionId == null) {
          errors.add('Cannot delete ${tx.invoiceReference}: missing ID.');
          continue;
        }
        try {
          final response = await _service.deleteCustomerTransaction(tx.transactionId!);
          if (response.statusCode == 200 || response.statusCode == 204) {
            successCount++;
          } else {
            errors.add('Failed to delete ${tx.invoiceReference}: ${response.statusCode}');
          }
        } catch (e) {
          errors.add('Error deleting ${tx.invoiceReference}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchTransactions();

      String message;
      if (errors.isEmpty) {
        message = 'Successfully deleted $successCount entries!';
      } else {
        message = 'Deleted $successCount entries successfully.\n\nErrors:\n${errors.join('\n')}';
      }
      _showSuccessDialog(errors.isEmpty ? 'Success' : 'Partial Success', message);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorDialog('Error', 'An error occurred during deletion: $e');
    }
  }

  void _showEditTransactionDialog(CustomerTransaction tx) {
    final TextEditingController editInvoiceController =
        TextEditingController(text: tx.invoiceReference);
    DateTime editDate = tx.transactionDate;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Editing items for a submitted sale is not allowed. You can only update the invoice reference and date.'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: editInvoiceController,
                        decoration: const InputDecoration(
                          labelText: 'Invoice Reference',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: editDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              editDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Transaction Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('yyyy-MM-dd').format(editDate)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {

                    Navigator.of(context).pop();
                    _showErrorDialog('Not Implemented',
                        'not yet implemented');
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

  Widget _buildCartList(StateSetter setStateDialog) {
    if (_itemsInCart.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No items added yet.'),
      ));
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: _itemsInCart.length,
        itemBuilder: (context, index) {
          final item = _itemsInCart[index];
          return Card(
            elevation: 1,
            child: ListTile(
              title: Text(item.itemDescription),
              subtitle: Text(
                  '${item.quantity} x \$${item.unitRetailPrice.toStringAsFixed(2)} from ${item.location}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setStateDialog(() {
                     _itemsInCart.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayTransactions.length : _rowsPerPage;
    final endIndex = showAll 
        ? _displayTransactions.length
        : (_startIndex + effectiveRowsPerPage > _displayTransactions.length)
            ? _displayTransactions.length
            : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Transactions (Sales)',
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
                                              hintText: 'Search by Invoice or Customer ID...',
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
                                      'New Sale',
                                      Icons.add,
                                      _showAddTransactionDialog,
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
                                      _selectedTransactionForEdit == null 
                                          ? null 
                                          : () => _showEditTransactionDialog(_selectedTransactionForEdit!),
                                      isEnabled: _selectedTransactionForEdit != null,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      'Delete',
                                      Icons.delete,
                                      _selectedTransactions.isEmpty
                                          ? null
                                          : () => _showDeleteConfirmationDialog(_selectedTransactions.first),
                                      isEnabled: _selectedTransactions.isNotEmpty,
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
                                                      : 'Search by Invoice Ref or Customer ID',
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
                                    onPressed: _showAddTransactionDialog,
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
                                      isMediumScreen ? 'New' : 'New Sale',
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
                                    onPressed: _selectedTransactionForEdit == null 
                                        ? null 
                                        : () {
                                            _showEditTransactionDialog(_selectedTransactionForEdit!);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedTransactionForEdit != null ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedTransactionForEdit != null ? Colors.white : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Edit'
                                          : (_selectedTransactions.length > 1 ? 'Edit First Selected' : 'Edit Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTransactionForEdit != null ? const Color(0xFF01579B) : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedTransactions.isEmpty
                                        ? null
                                        : () {
                                            _showDeleteConfirmationDialog(_selectedTransactions.first);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedTransactions.isNotEmpty ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedTransactions.isNotEmpty ? const Color.fromARGB(255, 175, 54, 46) : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Delete'
                                          : (_selectedTransactions.length > 1 ? 'Delete Selected (${_selectedTransactions.length})' : 'Delete Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedTransactions.isNotEmpty ? Colors.white : Colors.grey[600],
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
                                          'Invoice Ref',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Transaction Date' : 'Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Customer ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Total Price',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: _displayTransactions.isEmpty
                                        ? [
                                            const DataRow(cells: [
                                              DataCell(Text('')),
                                              DataCell(Text('No results found', style: TextStyle(color: Colors.white))),
                                              DataCell(Text('')),
                                              DataCell(Text('')),
                                            ])
                                          ]
                                        : _buildDataRows(endIndex, constraints.maxWidth),
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

  List<DataRow> _buildDataRows(int endIndex, double screenWidth) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll 
        ? _displayTransactions 
        : _displayTransactions.sublist(_startIndex, endIndex);

    double getColumnWidth(double baseWidth, double factor) {
      if (screenWidth > 1400) return baseWidth * 1.2;
      if (screenWidth > 1200) return baseWidth;
      if (screenWidth > 800) return baseWidth * 0.8;
      if (screenWidth > 600) return baseWidth * 0.7;
      return baseWidth * 0.6;
    }

    final referenceWidth = getColumnWidth(150, 1.0);
    final dateWidth = getColumnWidth(100, 1.0);
    final customerWidth = getColumnWidth(150, 1.0);
    final priceWidth = getColumnWidth(100, 1.0);

    return recordsToShow.map<DataRow>((data) {
      final isSelected = _selectedTransactions.contains(data);
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
              data.invoiceReference,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
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
            width: customerWidth,
            child: Tooltip(
              message: data.customerId,
              child: Text(
                data.customerId,
                softWrap: true,
                style: TextStyle(
                  height: 1.2,
                  fontSize: screenWidth > 600 ? 14 : 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: priceWidth,
            child: Text(
              '\$${data.totalRetailPrice?.toStringAsFixed(2) ?? 'N/A'}',
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
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
                ? 'Showing all ${_displayTransactions.length} entries'
                : '${_displayTransactions.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayTransactions.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _NeumorphicNavButton(
          icon: Icons.chevron_right,
          enabled: !showAll && endIndex < _displayTransactions.length,
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
  void _showErrorDialog(String title, String content) {
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
  
  void _showErrorListDialog(List<String> errors) {
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
  
  void _showSuccessDialog(String title, String content) {
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

  void _showLoadingDialog(String message) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }
}