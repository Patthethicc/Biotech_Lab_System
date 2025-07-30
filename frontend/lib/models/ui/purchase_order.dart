import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/purchase_order.dart';
import 'package:frontend/services/purchase_order_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';


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

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final PurchaseOrderService _poService = PurchaseOrderService();
  final TextEditingController _searchController = TextEditingController();

  List<PurchaseOrder> _allOrders = [];
  List<PurchaseOrder> _displayOrders = [];
  Set<PurchaseOrder> _selectedOrders = {};
  PurchaseOrder? _selectedOrderForEdit;

  bool _isLoading = true;
  bool _selectAll = false;
  bool _isHovered = false;

  int _startIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [10, 25, 50, 100];
  final int _showAllValue = -1;

  @override
  void initState() {
    super.initState();
    _fetchPurchaseOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOrders);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPurchaseOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedOrders = await _poService.fetchPurchaseOrders();
      setState(() {
        _allOrders = fetchedOrders
          ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
        _displayOrders = List.from(_allOrders);
        _isLoading = false;
        _clearSelection();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showDialog('Error', 'Failed to load purchase orders: $e');
      }
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayOrders = _allOrders.where((order) {
          return order.purchaseOrderCode.toLowerCase().contains(query);
        }).toList();
      } else {
        _displayOrders = List.from(_allOrders);
      }
      _clearSelection();
      _startIndex = 0;
    });
  }
  
  void _clearSelection() {
      _selectedOrders.clear();
      _selectedOrderForEdit = null;
      _selectAll = false;
  }

  void _resetToFullList() {
    setState(() {
      _searchController.clear();
      _displayOrders = List.from(_allOrders);
      _startIndex = 0;
      _clearSelection();
    });
  }

  void nextPage() {
    if (_rowsPerPage == _showAllValue) return;
    setState(() {
      if (_startIndex + _rowsPerPage < _displayOrders.length) {
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
        _clearSelection();
      } else {
        _selectedOrders = Set.from(_displayOrders);
        _selectAll = true;
        _selectedOrderForEdit = _selectedOrders.isNotEmpty ? _selectedOrders.first : null;
      }
    });
  }

  void _toggleOrderSelection(PurchaseOrder order) {
    setState(() {
      if (_selectedOrders.contains(order)) {
        _selectedOrders.remove(order);
        if (_selectedOrderForEdit == order) {
          _selectedOrderForEdit = _selectedOrders.isNotEmpty ? _selectedOrders.first : null;
        }
      } else {
        _selectedOrders.add(order);
        _selectedOrderForEdit = order;
      }
      _selectAll = _selectedOrders.length == _displayOrders.length && _displayOrders.isNotEmpty;
    });
  }

  void _changeRowsPerPage(int newRowsPerPage) {
    setState(() {
      _rowsPerPage = newRowsPerPage;
      _startIndex = 0;
       _selectAll = _selectedOrders.length == _displayOrders.length && _displayOrders.isNotEmpty;
    });
  }

  // In frontend/purchase_order.dart

// REPLACE your existing _showAddDialog with this one.
void _showAddDialog() {
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final quantityController = TextEditingController();
  final costController = TextEditingController();
  DateTime? orderDate;
  DateTime? deliveryDate;

  String? selectedPoFileName;
  Uint8List? selectedPoFileBytes;
  String? selectedPackingListFileName;
  Uint8List? selectedPackingListFileBytes;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Purchase Order'),
        content: Form(
          key: _formKey,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              
              // --- KEY CHANGE: Simplified helper functions ---
              // This is a more direct way to handle the state update.
              Future<void> _pickPoFile() async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null && result.files.single.bytes != null) {
                  setStateDialog(() {
                    selectedPoFileName = result.files.single.name;
                    selectedPoFileBytes = result.files.single.bytes;
                  });
                }
              }

              Future<void> _pickPackingListFile() async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                if (result != null && result.files.single.bytes != null) {
                  setStateDialog(() {
                    selectedPackingListFileName = result.files.single.name;
                    selectedPackingListFileBytes = result.files.single.bytes;
                  });
                }
              }
              // --- END OF KEY CHANGE ---

              return SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Order Code',
                          prefixIcon: Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text("Purchase Order File (Optional)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: -2,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              child: Text(
                                selectedPoFileName ?? 'No file selected',
                                style: TextStyle(
                                    color: selectedPoFileName != null
                                        ? Colors.black
                                        : Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // --- KEY CHANGE: Directly call the helper function ---
                          NeumorphicButton(
                            onPressed: _pickPoFile,
                            child: const Text('Select File'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("Supplier's Packing List (Optional)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: -2,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              child: Text(
                                selectedPackingListFileName ?? 'No file selected',
                                style: TextStyle(
                                    color: selectedPackingListFileName != null
                                        ? Colors.black
                                        : Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // --- KEY CHANGE: Directly call the helper function ---
                          NeumorphicButton(
                            onPressed: _pickPackingListFile,
                            child: const Text('Select File'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity Purchased',
                          prefixIcon: Icon(Icons.shopping_cart),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null ||
                              int.parse(value) <= 0) {
                            return 'Enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: orderDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              orderDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Order Date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            errorText: orderDate == null ? 'Required' : null,
                          ),
                          child: Text(orderDate != null
                              ? DateFormat('yyyy-MM-dd').format(orderDate!)
                              : 'Select Order Date'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: deliveryDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              deliveryDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Expected Delivery Date',
                            prefixIcon: const Icon(Icons.delivery_dining),
                            border: const OutlineInputBorder(),
                            errorText:
                                deliveryDate == null ? 'Required' : null,
                          ),
                          child: Text(deliveryDate != null
                              ? DateFormat('yyyy-MM-dd').format(deliveryDate!)
                              : 'Select Expected Delivery Date'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: costController,
                        decoration: const InputDecoration(
                          labelText: 'Cost',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 0) {
                            return 'Enter a valid cost';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  orderDate != null &&
                  deliveryDate != null) {
                String? poFileAsBase64;
                if (selectedPoFileBytes != null) {
                  poFileAsBase64 = base64Encode(selectedPoFileBytes!);
                }

                String? packingListAsBase64;
                if (selectedPackingListFileBytes != null) {
                  packingListAsBase64 =
                      base64Encode(selectedPackingListFileBytes!);
                }

                final newOrder = PurchaseOrder(
                  purchaseOrderCode: codeController.text,
                  purchaseOrderFile: poFileAsBase64,
                  suppliersPackingList: packingListAsBase64,
                  quantityPurchased: int.parse(quantityController.text),
                  orderDate: orderDate!,
                  expectedDeliveryDate: deliveryDate!,
                  cost: double.parse(costController.text),
                );

                try {
                  await _poService.addPurchaseOrder(newOrder);

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showDialog(
                        'Success', 'Purchase Order added successfully!');
                    _fetchPurchaseOrders();
                  }
                } catch (e) {
                  _showDialog('Error', 'Failed to add purchase order: $e');
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

  void _showEditDialog(PurchaseOrder order) {
    final _formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: order.purchaseOrderCode);
    final quantityController = TextEditingController(text: order.quantityPurchased.toString());
    final costController = TextEditingController(text: order.cost.toString());
    DateTime? orderDate = order.orderDate;
    DateTime? deliveryDate = order.expectedDeliveryDate;

    String? selectedPoFileName;
    Uint8List? selectedPoFileBytes;
    String? selectedPackingListFileName;
    Uint8List? selectedPackingListFileBytes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit PO: ${order.purchaseOrderCode}'),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                Future<void> _pickPoFile() async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                  if (result != null && result.files.single.bytes != null) {
                    setStateDialog(() {
                      selectedPoFileName = result.files.single.name;
                      selectedPoFileBytes = result.files.single.bytes;
                    });
                  }
                }

                Future<void> _pickPackingListFile() async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                  if (result != null && result.files.single.bytes != null) {
                    setStateDialog(() {
                      selectedPackingListFileName = result.files.single.name;
                      selectedPackingListFileBytes = result.files.single.bytes;
                    });
                  }
                }

                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: codeController,
                          readOnly: true, // This makes the field non-editable
                          decoration: const InputDecoration(
                            labelText: 'Purchase Order Code',
                            filled: true,
                            fillColor: Color.fromARGB(255, 232, 232, 232)
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text("Replace Purchase Order File (Optional)"),
                        const SizedBox(height: 4),
                        Text('Current: ${order.hasPurchaseOrderFile ? "File exists" : "No file"}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text(selectedPoFileName ?? 'Select new file...')),
                            ElevatedButton(onPressed: _pickPoFile, child: const Text('Select')),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const Text("Replace Packing List (Optional)"),
                        const SizedBox(height: 4),
                        Text('Current: ${order.hasSuppliersPackingList ? "File exists" : "No file"}', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Text(selectedPackingListFileName ?? 'Select new file...')),
                            ElevatedButton(onPressed: _pickPackingListFile, child: const Text('Select')),
                          ],
                        ),
                        const SizedBox(height: 16),
                
                        TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(labelText: 'Quantity Purchased'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: orderDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                orderDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Order Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(),
                              errorText: orderDate == null ? 'Required' : null,
                            ),
                            child: Text(orderDate != null
                                ? DateFormat('yyyy-MM-dd').format(orderDate!)
                                : 'Select Order Date'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: deliveryDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                deliveryDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Expected Delivery Date',
                              prefixIcon: const Icon(Icons.delivery_dining),
                              border: const OutlineInputBorder(),
                              errorText:
                                  deliveryDate == null ? 'Required' : null,
                            ),
                            child: Text(deliveryDate != null
                                ? DateFormat('yyyy-MM-dd').format(deliveryDate!)
                                : 'Select Expected Delivery Date'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: costController,
                          decoration: const InputDecoration(labelText: 'Cost'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String? poFileAsBase64;
                  if (selectedPoFileBytes != null) {
                    poFileAsBase64 = base64Encode(selectedPoFileBytes!);
                  }

                  String? packingListAsBase64;
                  if (selectedPackingListFileBytes != null) {
                    packingListAsBase64 = base64Encode(selectedPackingListFileBytes!);
                  }

                  final updatedOrder = PurchaseOrder(
                    purchaseOrderCode: codeController.text,
                    purchaseOrderFile: selectedPoFileBytes != null ? poFileAsBase64 : order.purchaseOrderFile,
                    suppliersPackingList: selectedPackingListFileBytes != null ? packingListAsBase64 : order.suppliersPackingList,
                    quantityPurchased: int.parse(quantityController.text),
                    orderDate: orderDate!,
                    expectedDeliveryDate: deliveryDate!,
                    cost: double.parse(costController.text),
                  );

                  try {
                    await _poService.updatePurchaseOrder(updatedOrder);
                    if(mounted) {
                      Navigator.pop(context);
                      _showDialog('Success', 'Purchase Order updated.');
                      _fetchPurchaseOrders();
                    }
                  } catch (e) {
                    _showDialog('Error', 'Failed to update: $e');
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    final selectedCount = _selectedOrders.length;
     final singleId = _selectedOrders.isNotEmpty ? _selectedOrders.first.purchaseOrderCode : "";
    final message = selectedCount > 1
        ? 'Are you sure you want to delete $selectedCount selected purchase orders? This action cannot be undone.'
        : 'Are you sure you want to delete the purchase order with Code: $singleId? This action cannot be undone.';

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
                _deleteSelectedOrders();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSelectedOrders() async {
    final ordersToDelete = List.from(_selectedOrders);
    
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
              Text('Please wait while the orders are being deleted.'),
            ],
          ),
        );
      },
    );

    try {
      int successCount = 0;
      List<String> errors = [];

      for (PurchaseOrder order in ordersToDelete) {
        try {
          await _poService.deletePurchaseOrder(order.purchaseOrderCode);
          successCount++;
        } catch (e) {
          errors.add('Error deleting ${order.purchaseOrderCode}: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchPurchaseOrders(); //This already clears selection

      if (!mounted) return;

      String message;
      if (errors.isEmpty) {
        message = 'Successfully deleted $successCount order(s)!';
      } else {
        message = 'Deleted $successCount order(s) successfully.\n\nErrors:\n${errors.join('\n')}';
      }

      _showDialog(errors.isEmpty ? 'Success' : 'Partial Success', message);
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

  Future<void> _downloadAndOpenFile(String poCode, String fileName, {bool isPackingList = false}) async {
    final String endpointPath = isPackingList
        ? '/PO/v1/getPO/$poCode/packinglist'
        : '/PO/v1/getPO/$poCode/file';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AlertDialog(
        title: Text('Downloading...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while the file is being downloaded.'),
          ],
        ),
      ),
    );

    try {
      final Uint8List fileBytes = await _poService.downloadFile(endpointPath);

      if (mounted) Navigator.of(context).pop();

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: fileBytes,
      );
      
      if (mounted) {
        _showDialog('Success', 'File saved successfully.');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showDialog('Error', 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final bool showAll = _rowsPerPage == _showAllValue;
    final int effectiveRowsPerPage = showAll ? _displayOrders.length : _rowsPerPage;
    final endIndex = showAll
        ? _displayOrders.length
        : (_startIndex + effectiveRowsPerPage > _displayOrders.length)
            ? _displayOrders.length
            : _startIndex + effectiveRowsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase Orders',
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
                                              hintText: 'Search by PO Code...',
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
                                      _showAddDialog,
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
                                      _selectedOrderForEdit == null 
                                          ? null 
                                          : () => _showEditDialog(_selectedOrderForEdit!),
                                      isEnabled: _selectedOrderForEdit != null,
                                      isSmall: true,
                                    ),
                                     _buildResponsiveButton(
                                      'Delete',
                                      Icons.delete,
                                      _selectedOrders.isEmpty
                                          ? null
                                          : () => _showDeleteConfirmationDialog(),
                                      isEnabled: _selectedOrders.isNotEmpty,
                                      isDelete: true,
                                      isSmall: true,
                                    ),
                                  ],
                                )
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
                                                      : 'Search by Purchase Order Code',
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
                                    onPressed: _showAddDialog,
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
                                      isMediumScreen ? 'Add' : 'Add Order',
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
                                    onPressed: _selectedOrderForEdit == null 
                                        ? null 
                                        : () {
                                            _showEditDialog(_selectedOrderForEdit!);
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedOrderForEdit != null ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedOrderForEdit != null ? Colors.white : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Edit'
                                          : (_selectedOrders.length > 1 ? 'Edit First Selected' : 'Edit Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedOrderForEdit != null ? const Color(0xFF01579B) : Colors.grey[600],
                                        fontSize: isMediumScreen ? 13 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  child: NeumorphicButton(
                                    onPressed: _selectedOrders.isEmpty
                                        ? null
                                        : () {
                                            _showDeleteConfirmationDialog();
                                          },
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMediumScreen ? 16 : 24, 
                                      vertical: 10,
                                    ),
                                    style: NeumorphicStyle(
                                      depth: _selectedOrders.isNotEmpty ? 4 : 1,
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(30)),
                                      lightSource: LightSource.topLeft,
                                      color: _selectedOrders.isNotEmpty ? const Color.fromARGB(255, 175, 54, 46) : Colors.grey[300],
                                    ),
                                    child: Text(
                                      isMediumScreen 
                                          ? 'Delete'
                                          : (_selectedOrders.length > 1 ? 'Delete Selected (${_selectedOrders.length})' : 'Delete Selected'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedOrders.isNotEmpty ? Colors.white : Colors.grey[600],
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
                                          showCheckboxColumn: true,
                                          columnSpacing: constraints.maxWidth > 1200 ? 12.0 : 6.0,
                                          horizontalMargin: constraints.maxWidth > 800 ? 4.0 : 2.0,
                                          checkboxHorizontalMargin: 0.0,
                                          dataRowMaxHeight: 48.0,
                                          dataRowMinHeight: 40.0,
                                          headingRowHeight: constraints.maxWidth > 600 ? 52.0 : 44.0,
                                          columns: _buildDataColumns(constraints.maxWidth),
                                          rows: _displayOrders.isEmpty
                                              ? [
                                                  const DataRow(cells: [
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('')),
                                                    DataCell(Text('No results found', style: TextStyle(color: Colors.white))),
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

  List<DataColumn> _buildDataColumns(double screenWidth) {
      return <DataColumn>[
      DataColumn(
        label: Text(
          screenWidth > 800 ? 'Purchase Order Code' : 'PO Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          screenWidth > 1200 ? 'Purchase Order File' : 'Purchase Order File',
           style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      DataColumn(
        label: Text(
           screenWidth > 1200 ? "Supplier's Packing List" : "Sup. List",
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
          screenWidth > 800 ? 'Order Date' : 'Ordered',
           style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          screenWidth > 800 ? 'Expected Delivery' : 'Delivery',
           style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Cost',
           style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildDataRows(DateFormat formatter, int endIndex, double screenWidth) {
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll
        ? _displayOrders
        : _displayOrders.sublist(_startIndex, endIndex);
    
    final numberFormatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return recordsToShow.map<DataRow>((order) {
      final isSelected = _selectedOrders.contains(order);
      final subtleBlueTint1 = const Color.fromRGBO(241, 245, 255, 1);
      final subtleBlueTint2 = const Color.fromRGBO(230, 240, 255, 1);
      final rowColor = counter.isEven ? subtleBlueTint1 : subtleBlueTint2;
      counter++;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) {
          _toggleOrderSelection(order);
        },
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(Text(order.purchaseOrderCode)),
          DataCell(
            (order.hasPurchaseOrderFile)
                ? InkWell(
                  onTap: () {
                    final fileName = '${order.purchaseOrderCode}-PO.pdf';
                    _downloadAndOpenFile(order.purchaseOrderCode, fileName, isPackingList: false);
                  },
                  child: const Text('View/Download', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
                )
              : const Text('N/A'),
          ),
          DataCell(
            (order.hasSuppliersPackingList)
                ? InkWell(
                  onTap: () {
                    final fileName = '${order.purchaseOrderCode}-PackingList.pdf';
                    _downloadAndOpenFile(order.purchaseOrderCode, fileName, isPackingList: true);
                  },
                  child: const Text('View/Download', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
                )
              : const Text('N/A'),
          ),
          DataCell(Text(order.quantityPurchased.toString())),
          DataCell(Text(formatter.format(order.orderDate))),
          DataCell(Text(formatter.format(order.expectedDeliveryDate))),
          DataCell(Text(numberFormatter.format(order.cost))),
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
                ? 'Showing all ${_displayOrders.length} orders'
                : '${_displayOrders.isEmpty ? 0 : _startIndex + 1} – $endIndex of ${_displayOrders.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        _NeumorphicNavButton(
          icon: Icons.chevron_right,
          enabled: !showAll && endIndex < _displayOrders.length,
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
}