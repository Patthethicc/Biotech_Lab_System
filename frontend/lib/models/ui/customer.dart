import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/customer_model.dart';
import 'package:frontend/services/customer_service.dart'; 
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

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomerService _service = CustomerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _salesRepController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Customer> _customerRecords = [];
  List<Customer> _allCustomerRecords = [];
  List<Customer> _displayCustomerRecords = [];
  bool _isLoading = true;
  bool _isHovered = false;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100, 250];
  final int _showAllValue = -1;

  bool _dontAskAgain = false;
  Customer? _selectedCustomerForEdit;
  Set<Customer> _selectedCustomers = {};
  bool _selectAll = false;

  bool _isValidatingName = false;
  bool _customerNameExists = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _salesRepController.dispose();
    _searchController.removeListener(_filterCustomers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final customers = await _service.getCustomers();
      setState(() {
        _customerRecords.clear();
        _allCustomerRecords.clear();
        _displayCustomerRecords.clear();
        _selectedCustomers.clear();
        _selectedCustomerForEdit = null;
        _selectAll = false;
        
        _customerRecords = customers
            ..sort((a, b) => a.name.compareTo(b.name));
        _displayCustomerRecords = List.from(_allCustomerRecords);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching data: $e');
      if (mounted) {
        _showDialog('Error', 'Failed to load customer data: $e');
      }
    }
  }

  Future<void> _validateName(String name) async {
    if (name.trim().isEmpty) {
      setState(() {
        _isValidatingName = false;
        _customerNameExists = false;
      });
      return;
    }

    setState(() {
      _isValidatingName = true;
    });

    try {
      final exists = await _service.customerExists(name.trim());
      setState(() {
        _isValidatingName = false;
        _customerNameExists = exists;
      });
    } catch (e) {
      setState(() {
        _isValidatingName = false;
        _customerNameExists = false;
      });
      debugPrint('Error validating name: $e');
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayCustomerRecords = _allCustomerRecords.where((customer) {
          final nameMatch = customer.name.toLowerCase().contains(query);
          final addressMatch = customer.address.toLowerCase().contains(query);
          final salesRepMatch = customer.salesRepresentative.toLowerCase().contains(query);
          return nameMatch || addressMatch || salesRepMatch;
        }).toList();
      } else {
        _displayCustomerRecords = List.from(_allCustomerRecords);
      }
      _startIndex = 0; 
      
      _selectedCustomers.removeWhere((entry) => !_displayCustomerRecords.contains(entry));
      _selectedCustomerForEdit = _selectedCustomers.isNotEmpty ? _selectedCustomers.first : null;
      _selectAll = _selectedCustomers.length == _displayCustomerRecords.length && _displayCustomerRecords.isNotEmpty;
    });
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayCustomerRecords = List.from(_allCustomerRecords);
      _startIndex = 0;
      _selectedCustomers.clear();
      _selectedCustomerForEdit = null;
      _selectAll = false;
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return; 
    setState(() {
      if (_startIndex + _rowsPerPage < _displayCustomerRecords.length) {
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
        _selectedCustomers.clear();
        _selectAll = false;
        _selectedCustomerForEdit = null;
      } else {
        _selectedCustomers = Set.from(_displayCustomerRecords);
        _selectAll = true;
        _selectedCustomerForEdit = _selectedCustomers.isNotEmpty ? _selectedCustomers.first : null;
      }
    });
  }

  void _toggleEntrySelection(Customer customer) {
    setState(() {
      if (_selectedCustomers.contains(customer)) {
        _selectedCustomers.remove(customer);
        if (_selectedCustomerForEdit == customer) {
          _selectedCustomerForEdit = _selectedCustomers.isNotEmpty ? _selectedCustomers.first : null;
        }
      } else {
        _selectedCustomers.add(customer);
        _selectedCustomerForEdit = customer;
      }
      
      _selectAll = _selectedCustomers.length == _displayCustomerRecords.length && _displayCustomerRecords.isNotEmpty;
    });
  }

  void _changeRowsPerPage(int newRowsPerPage) {
    if (newRowsPerPage > 1000 || newRowsPerPage == _showAllValue) {
      final int totalEntries = newRowsPerPage == _showAllValue ? _displayCustomerRecords.length : newRowsPerPage;
      if (totalEntries > 1000) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Performance Warning'),
              content: Text(
                'You are about to display ${newRowsPerPage == _showAllValue ? "all ${_displayCustomerRecords.length}" : totalEntries} entries at once. '
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
                      _selectAll = _selectedCustomers.length == _displayCustomerRecords.length && _displayCustomerRecords.isNotEmpty;
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
      _selectAll = _selectedCustomers.length == _displayCustomerRecords.length && _displayCustomerRecords.isNotEmpty;
    });
  }

  Future<void> _submitCustomerData() async {
    final newCustomer = {
      "name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "salesRepresentative": _salesRepController.text.trim(),
    };

    debugPrint(jsonEncode(newCustomer)); 

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
              Text('Please wait while customer data is being submitted.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.createCustomer(newCustomer);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchCustomers(); 
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('New customer has been successfully added!'),
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
        _showDialog('Error', 'Failed to submit data. Server responded with ${response.statusCode}: ${response.body}.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred: $e');
    }
  }

  void _showAddCustomerDialog() {
    _nameController.clear();
    _addressController.clear();
    _salesRepController.clear();
    _nameError = null;
    _customerNameExists = false;
    _isValidatingName = false;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return StatefulBuilder( 
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Customer'),
              content: SizedBox(
                width: 500, 
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: (value) => _validateName(value),
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Enter customer name',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: _buildReferenceValidationIcon(),
                          errorText: _nameError,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter customer address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on), 
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _salesRepController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Sales Representative',
                          hintText: 'Enter sales representative name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge), 
                        ),
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
                    _validateAndSubmitAdd();
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

  void _validateAndSubmitAdd() {
    List<String> errors = [];

    if (_nameController.text.trim().isEmpty) {
      errors.add('Customer Name is required');
    }
    if (_addressController.text.trim().isEmpty) {
      errors.add('Address is required');
    }
    if (_salesRepController.text.trim().isEmpty) {
      errors.add('Sales Representative is required');
    }
    if (_customerNameExists) {
      errors.add('A customer with this name already exists.');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    if (!_dontAskAgain) {
      _showConfirmationDialog(isEdit: false);
    } else {
      Navigator.of(context).pop();
      _submitCustomerData();
    }
  }

  void _showEditCustomerDialog(Customer customer) {
    _nameController.text = customer.name;
    _addressController.text = customer.address;
    _salesRepController.text = customer.salesRepresentative;
    
    _nameError = null;
    _customerNameExists = false;
    _isValidatingName = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Customer'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Enter customer name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter customer address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on), 
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _salesRepController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Sales Representative',
                          hintText: 'Enter sales representative name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge), 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectedCustomerForEdit = null; 
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _validateAndSubmitEdit(customer);
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

  void _validateAndSubmitEdit(Customer originalCustomer) {
    List<String> errors = [];

    if (_nameController.text.trim().isEmpty) {
      errors.add('Customer Name is required');
    }
    if (_addressController.text.trim().isEmpty) {
      errors.add('Address is required');
    }
    if (_salesRepController.text.trim().isEmpty) {
      errors.add('Sales Representative is required');
    }

    if (errors.isNotEmpty) {
      _showErrorDialog(errors);
      return;
    }

    if (!_dontAskAgain) {
      _showConfirmationDialog(isEdit: true, customerToUpdate: originalCustomer);
    } else {
      Navigator.of(context).pop();
      _updateCustomerData(originalCustomer.customerId);
    }
  }

  Future<void> _updateCustomerData(String customerId) async {
    final updatedCustomer = {
      "name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "salesRepresentative": _salesRepController.text.trim(),
    };

    debugPrint('Updating: ${jsonEncode(updatedCustomer)}');

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
              Text('Please wait while customer data is being updated.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.updateCustomer(customerId, updatedCustomer);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        await _fetchCustomers(); 
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Customer data has been successfully updated!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          _selectedCustomers.clear();
          _selectedCustomerForEdit = null; 
          _selectAll = false;
        });
      } else {
        if (!mounted) return;
        _showDialog('Error', 'Failed to update data. Server responded with ${response.statusCode}: ${response.body}.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred during update: $e');
    }
  }

  void _showDeleteConfirmationDialog() {
    final selectedCount = _selectedCustomers.length;
    final customerName = _selectedCustomers.first.name;

    final message = selectedCount > 1 
        ? 'Are you sure you want to delete $selectedCount selected customers? This action cannot be undone.'
        : 'Are you sure you want to delete the customer: $customerName? This action cannot be undone.';

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
                  _deleteMultipleCustomers();
                } else {
                  _deleteCustomer(_selectedCustomers.first.customerId);
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

  Future<void> _deleteMultipleCustomers() async {
    final customersToDelete = List.from(_selectedCustomers);
    
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
              Text('Please wait while the customers are being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      int successCount = 0;
      List<String> errors = [];

      for (Customer customer in customersToDelete) {
        try {
          final response = await _service.deleteCustomer(customer.customerId);
          if (response.statusCode == 200 || response.statusCode == 204) {
            successCount++;
          } else {
            errors.add('Failed to delete ${customer.name}: ${response.statusCode}');
          }
        } catch (e) {
          errors.add('Error deleting ${customer.name}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchCustomers();
      setState(() {
        _selectedCustomers.clear();
        _selectedCustomerForEdit = null;
        _selectAll = false;
      });

      if (!mounted) return;

      String message;
      if (errors.isEmpty) {
        message = 'Successfully deleted $successCount customers!';
      } else {
        message = 'Deleted $successCount customers successfully.\n\nErrors:\n${errors.join('\n')}';
      }

      _showDialog(errors.isEmpty ? 'Success' : 'Partial Success', message);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showDialog('Error', 'An error occurred during deletion: $e');
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
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
              Text('Please wait while the customer is being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      final response = await _service.deleteCustomer(customerId);

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _fetchCustomers(); 
        setState(() {
          _selectedCustomers.clear();
          _selectedCustomerForEdit = null; 
          _selectAll = false;
        });
        if (!mounted) return;
        _showDialog('Success', 'Customer successfully deleted!');
      } else {
        if (!mounted) return;
        _showDialog('Error', 'Failed to delete customer. Server responded with ${response.statusCode}: ${response.body}.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      _showDialog('Error', 'An error occurred during deletion: $e');
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

  void _showConfirmationDialog({required bool isEdit, Customer? customerToUpdate}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEdit ? 'Confirm Changes' : 'Confirm New Customer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please confirm the following data:'),
                  const SizedBox(height: 12),
                  Text('Customer Name: ${_nameController.text}'),
                  Text('Address: ${_addressController.text}'),
                  Text('Sales Rep: ${_salesRepController.text}'),
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
                    Navigator.of(context).pop();

                    if (isEdit) {
                      _updateCustomerData(customerToUpdate!.customerId);
                    } else {
                      _submitCustomerData();
                    }
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

  @override
  Widget build(BuildContext context) {
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayCustomerRecords.length : _rowsPerPage;
    final endIndex = showAll 
        ? _displayCustomerRecords.length
        : (_startIndex + effectiveRowsPerPage > _displayCustomerRecords.length)
            ? _displayCustomerRecords.length
            : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer List',
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
                                              hintText: 'Search by Name, Address...',
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
                                      _showAddCustomerDialog,
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
                                      _selectedCustomerForEdit == null 
                                          ? null 
                                          : () => _showEditCustomerDialog(_selectedCustomerForEdit!),
                                      isEnabled: _selectedCustomerForEdit != null,
                                      isSmall: true,
                                    ),
                                    _buildResponsiveButton(
                                      'Delete',
                                      Icons.delete,
                                      _selectedCustomers.isEmpty
                                          ? null
                                          : _showDeleteConfirmationDialog,
                                      isEnabled: _selectedCustomers.isNotEmpty,
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
                                                      : 'Search by Name, Address, or Sales Rep',
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
                                    onPressed: _showAddCustomerDialog,
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
                                      isMediumScreen ? 'Add' : 'Add Customer',
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
                                    onPressed: _selectedCustomerForEdit == null 
                                        ? null 
                                        : () {
                                            _showEditCustomerDialog(_selectedCustomerForEdit!);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedCustomerForEdit != null ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedCustomerForEdit != null ? Colors.white : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Edit'
                                          : (_selectedCustomers.length > 1 ? 'Edit First Selected' : 'Edit Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedCustomerForEdit != null ? const Color(0xFF01579B) : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedCustomers.isEmpty
                                        ? null
                                        : _showDeleteConfirmationDialog,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedCustomers.isNotEmpty ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedCustomers.isNotEmpty ? const Color.fromARGB(255, 175, 54, 46) : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Delete'
                                          : (_selectedCustomers.length > 1 ? 'Delete Selected (${_selectedCustomers.length})' : 'Delete Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedCustomers.isNotEmpty ? Colors.white : Colors.grey[600],
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
                                      dataRowMaxHeight: 52.0,
                                      dataRowMinHeight: 44.0,
                                      headingRowHeight: constraints.maxWidth > 600 ? 52.0 : 44.0,
                                    columns: <DataColumn>[
                                      const DataColumn(
                                        label: Text(
                                          'Customer Name',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Address',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          constraints.maxWidth > 800 ? 'Sales Representative' : 'Sales Rep',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: _displayCustomerRecords.isEmpty
                                        ? [
                                            const DataRow(cells: [
                                              DataCell(Text('')),
                                              DataCell(Text('No results found', style: TextStyle(color: Colors.white))),
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
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll 
        ? _displayCustomerRecords 
        : _displayCustomerRecords.sublist(_startIndex, endIndex);

    double getColumnWidth(double baseWidth, double factor) {
      if (screenWidth > 1400) return baseWidth * 1.5;
      if (screenWidth > 1200) return baseWidth * 1.2;
      if (screenWidth > 800) return baseWidth;
      if (screenWidth > 600) return baseWidth * 0.8;
      return baseWidth * 0.7;
    }

    final nameWidth = getColumnWidth(150, 1.0);
    final addressWidth = getColumnWidth(250, 1.5);
    final salesRepWidth = getColumnWidth(150, 1.0);

    return recordsToShow.map<DataRow>((data) {
      final isSelected = _selectedCustomers.contains(data);
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
            width: nameWidth,
            child: Text(
              data.name,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          )),
          DataCell(SizedBox(
            width: addressWidth,
            child: Text(
              data.address,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          )),
          DataCell(SizedBox(
            width: salesRepWidth,
            child: Text(
              data.salesRepresentative,
              softWrap: true,
              style: TextStyle(
                height: 1.2,
                fontSize: screenWidth > 600 ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
                ? 'Showing all ${_displayCustomerRecords.length} entries'
                : '${_displayCustomerRecords.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayCustomerRecords.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _NeumorphicNavButton(
          icon: Icons.chevron_right,
          enabled: !showAll && endIndex < _displayCustomerRecords.length,
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
    if (_isValidatingName) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_customerNameExists) {
      return Tooltip(
        message: 'A customer with this name already exists',
        child: Icon(
          Icons.warning,
          color: Colors.orange[600],
          size: 24,
        ),
      );
    }

    if (_nameController.text.isNotEmpty && !_isValidatingName && !_customerNameExists) {
       return const Icon(
        Icons.check,
        color: Colors.green,
        size: 24,
      );
    }

    return const SizedBox.shrink();
  }
}