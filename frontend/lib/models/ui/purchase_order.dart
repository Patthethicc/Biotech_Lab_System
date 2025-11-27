import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/api/purchase_order.dart';
import 'package:frontend/services/purchase_order_service.dart';
import 'package:frontend/services/brand_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
// import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:docx_template/docx_template.dart';
// import 'package:file_saver/file_saver.dart';


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
  final BrandService _brandService = BrandService();
  List<PurchaseOrder> _allOrders = [];
  List<PurchaseOrder> _displayOrders = [];
  Set<PurchaseOrder> _selectedOrders = {};
  PurchaseOrder? _selectedOrderForEdit;
  List<Map<String, dynamic>> _availableBrands = [];
  String? selectedbrand;

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
    _fetchBrands();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOrders);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final brands = await _brandService.getBrands();

      final brandList = brands.map((b) => {'id': b.brandId, 'name': b.brandName}).toList();

      if(!mounted) return;
      setState(() {
        _availableBrands = brandList;
      });
    } catch (e) {
      if(mounted){
        _showDialog('Error', 'Failed to load brands: $e');
      }
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPurchaseOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetched = await _poService.fetchPurchaseOrders();

      final orders = List<PurchaseOrder>.from(fetched);

      // Sort by brand first, then itemCode (both case-insensitive).
      orders.sort((a, b) {
        final brandCmp = (a.brandName ?? '').toLowerCase().compareTo((b.brandName ?? '').toLowerCase());
        if (brandCmp != 0) return brandCmp;
        final codeA = a.itemCode?.toLowerCase() ?? '';
        final codeB = b.itemCode?.toLowerCase() ?? '';
        return codeA.compareTo(codeB);
      });

      if (!mounted) return;
      setState(() {
        _allOrders = orders;
        _displayOrders = List.from(_allOrders);
        _clearSelection();
      });
    } catch (e) {
      if (mounted) {
        _showDialog('Error', 'Failed to load purchase orders: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double get _grandTotalCost {
    return _displayOrders.fold(0.0, (sum, order) => sum + order.totalCost);
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        _displayOrders = _allOrders.where((order) {
          final ref = order.poPireference.toLowerCase();
          return ref.contains(query);
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

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();

    final itemController = TextEditingController();
    final descriptionController = TextEditingController();
    final packSizeController = TextEditingController();
    final quantityController = TextEditingController();
    final unitCostController = TextEditingController();
    final popiRefController = TextEditingController();

    Map<String, dynamic>? selectedBrand;
    num computedTotalCost = 0;

    void recalculateTotal() {
      final qty = num.tryParse(quantityController.text) ?? 0;
      final cost = num.tryParse(unitCostController.text) ?? 0;
      computedTotalCost = qty * cost;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Purchase Order'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: selectedBrand,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableBrands.isEmpty
                            ? [
                                const DropdownMenuItem<Map<String, dynamic>>(
                                  value: null,
                                  enabled: false,
                                  child: Text(
                                    'No brands available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ]
                            : _availableBrands.map((brand) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: brand,
                                  child: Text(brand['name']),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setStateDialog(() => selectedBrand = value);
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Product Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: packSizeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Pack Size',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setStateDialog(() {
                              recalculateTotal();
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: unitCostController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          decoration: const InputDecoration(
                            labelText: 'Unit Cost',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setStateDialog(() {
                              recalculateTotal();
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Total Cost',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            computedTotalCost.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: popiRefController,
                          decoration: const InputDecoration(
                            labelText: 'PO/PI Reference',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                if (formKey.currentState!.validate()) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Purchase Order'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Brand: ${selectedBrand!['name'] ?? ''}'),
                            Text('Description: ${descriptionController.text}'),
                            Text('Pack Size: ${packSizeController.text}'),
                            Text('Quantity: ${quantityController.text}'),
                            Text('Unit Cost: ${unitCostController.text}'),
                            Text('PO/PI Ref: ${popiRefController.text}'),
                            const SizedBox(height: 20),
                            const Text('Are you sure all information is correct?', 
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    final newOrder = PurchaseOrder(
                      itemCode: itemController.text,
                      brandId: selectedBrand!['id'],
                      productDescription: descriptionController.text,
                      packSize: int.tryParse(packSizeController.text) ?? 0,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                      unitCost: num.tryParse(unitCostController.text) ?? 0,
                      poPireference: popiRefController.text,
                      addedBy: 1,
                    );
                    print(newOrder.toJson());
                    try {
                      await _poService.addPurchaseOrder(newOrder);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      _showDialog('Success', 'Purchase Order added!');
                      _fetchPurchaseOrders();
                    } catch (e) {
                      if (!mounted) return;
                      _showDialog('Error', 'Failed to add purchase order: $e');
                    }
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
    final formKey = GlobalKey<FormState>();

    final itemController = TextEditingController(text: order.itemCode);
    final descriptionController = TextEditingController(text: order.productDescription);
    final packSizeController = TextEditingController(text: order.packSize.toString());
    final quantityController = TextEditingController(text: order.quantity.toString());
    final unitCostController = TextEditingController(text: order.unitCost.toString());
    final popiRefController = TextEditingController(text: order.poPireference);

    int? selectedBrandId = order.brandId;

    num computedTotalCost = order.totalCost;

    void recalculateTotal(){
      final qty = num.tryParse(quantityController.text) ?? 0;
      final cost = num.tryParse(unitCostController.text) ?? 0;
      computedTotalCost = qty * cost;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit PO: ${order.itemCode}'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialog) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<int>(
                          value: selectedBrandId,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableBrands.isEmpty
                              ? [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    enabled: false,
                                    child: Text('No brands available',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                ]
                              : _availableBrands.map((brand) {
                                  return DropdownMenuItem<int>(
                                    value: brand['id'],
                                    child: Text(brand['name']),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setStateDialog(() => selectedBrandId = value);
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Product Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: packSizeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
                          decoration: const InputDecoration(
                            labelText: 'Pack Size',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setStateDialog(() {
                              recalculateTotal();
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: unitCostController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],
                          decoration: const InputDecoration(
                            labelText: 'Unit Cost',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            setStateDialog(() {
                              recalculateTotal();
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Total Cost',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            computedTotalCost.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: popiRefController,
                          decoration: const InputDecoration(
                            labelText: 'POPI Reference',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if(formKey.currentState!.validate()) {
                  final brandName = _availableBrands
                    .firstWhere((b) => b['id'] == selectedBrandId, orElse: () => {'brandName': ''})['name'];
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Purchase Order'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Brand: $brandName'),
                            Text('Description: ${descriptionController.text}'),
                            Text('Pack Size: ${packSizeController.text}'),
                            Text('Quantity: ${quantityController.text}'),
                            Text('Unit Cost: ${unitCostController.text}'),
                            Text('PO/PI Ref: ${popiRefController.text}'),
                            const SizedBox(height: 20),
                            const Text('Are you sure all information is correct?', 
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        actions: [
                           TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );

                  if(confirmed == true) {
                    final updatedOrder = PurchaseOrder(
                      itemCode: itemController.text, 
                      brandId: selectedBrandId!, 
                      productDescription: descriptionController.text, 
                      packSize: int.tryParse(packSizeController.text) ?? 0, 
                      quantity: int.tryParse(quantityController.text) ?? 0, 
                      unitCost: num.tryParse(unitCostController.text) ?? 0, 
                      poPireference: popiRefController.text,
                      addedBy: order.addedBy,
                      dateTimeAdded: order.dateTimeAdded,
                    );

                    print(jsonEncode(updatedOrder));
                    try {
                      await _poService.updatePurchaseOrder(updatedOrder);
                      if(!context.mounted) return;
                      Navigator.of(context).pop();
                      _showDialog('Success', 'Purchase Order Updated!');
                      _fetchPurchaseOrders();
                    } catch (e) {
                      if(!mounted) return;
                      _showDialog('Error', 'Failed to update purchase order: $e');
                    }
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
    final singleId = _selectedOrders.isNotEmpty ? _selectedOrders.first.itemCode : "";
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
        final code = order.itemCode;

        if (code == null || code.isEmpty) {
          errors.add('Skipping an order with no item code.');
          continue;
        }

        try {
          await _poService.deletePurchaseOrder(code);
          successCount++;
        } catch (e) {
          errors.add('Error deleting $code: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      await _fetchPurchaseOrders();

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

  // Future<void> _downloadAndOpenFile(String itemCode, String fileName, {required String fileType}) async {
  //   String endpointPath;

  //   switch (fileType) {
  //     case 'packinglist':
  //       endpointPath = '/PO/v1/getPO/$itemCode/packinglist';
  //       break;
  //     case 'inventory':
  //       endpointPath = '/PO/v1/getPO/$itemCode/inventory'; 
  //       break;
  //     case 'file':
  //     default:
  //       endpointPath = '/PO/v1/getPO/$itemCode/file';
  //       break;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) => const AlertDialog(
  //       title: Text('Downloading...'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           CircularProgressIndicator(),
  //           SizedBox(height: 16),
  //           Text('Please wait while the file is being downloaded.'),
  //         ],
  //       ),
  //     ),
  //   );

  //   try {
  //     final Uint8List fileBytes = await _poService.downloadFile(endpointPath);

  //     if (mounted) Navigator.of(context).pop();

  //     await FileSaver.instance.saveFile(
  //       name: fileName,
  //       bytes: fileBytes,
  //     );
      
  //     if (mounted) {
  //       _showDialog('Success', 'File saved successfully.');
  //     }
  //   } catch (e) {
  //     if (mounted) Navigator.of(context).pop();
  //     _showDialog('Error', 'An error occurred: $e');
  //   }
  // }

  Future<void> _generateAndSavePDF(PurchaseOrder po, String brandName) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:(pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(po.poPireference, 
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, 
                    fontSize: 24
                  )
                ),
                pw.SizedBox(height: 24),
                pw.TableHelper.fromTextArray(
                  headers: ['Item Code', 'Brand', 'Product Description', 'Pack Size', 'Quantity', 'Unit Cost', 'Total Cost', 'PO/PI Reference'],
                  data: [[po.itemCode, brandName, po.productDescription, po.packSize, po.quantity, po.unitCost, po.totalCost, po.poPireference]],
                  border: pw.TableBorder.all(color: PdfColors.grey600, width: 1),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey800,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 12),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellAlignments: {
                    4: pw.Alignment.center,
                    5: pw.Alignment.centerRight,
                    6: pw.Alignment.centerRight,
                  },
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Purchase Order PDF',
        fileName: '${po.poPireference}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if(outputFile != null){
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
        _showDialog('Success', 'PDF Successfully Saved at $outputFile');
      }
    } catch (e) {
      _showDialog('Error', 'Error generating or saving PDF: $e');
    }
  }

  Future<void> _generateAndSaveDOCX(PurchaseOrder po, String brandName) async {
    try {
      final data = await rootBundle.load('Assets/Documents/template.docx');
      final bytes = data.buffer.asUint8List();

      final docx = await DocxTemplate.fromBytes(bytes);

      Content content = Content();

      content
        ..add(TextContent("itemCode", po.itemCode))
        ..add(TextContent("brandName", brandName))
        ..add(TextContent("packSize", po.packSize.toStringAsFixed(2)))
        ..add(TextContent("quantity", po.quantity.toString()))
        ..add(TextContent("unitCost", po.unitCost.toStringAsFixed(2)))
        ..add(TextContent("poPireference", po.poPireference))
        ..add(TextContent("productDescription", po.productDescription))
        ..add(TextContent("totalCost", po.totalCost.toStringAsFixed(2)));

      final generatedBytes = await docx.generate(content);
      
      if (generatedBytes == null) {
        _showDialog('Error', 'DOCX generation failed');
        return;
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Purchase Order Docx',
        fileName: '${po.poPireference}.docx',
        type: FileType.custom,
        allowedExtensions: ['docx'],
      );

      if(outputFile != null){
        final file = File(outputFile);
        await file.writeAsBytes(generatedBytes);
        _showDialog('Success', 'DOCX Successfully Saved at $outputFile');
      }
    } catch (e) {
      _showDialog('Error', 'Error generating or saving DOCX: $e');
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
                                                    DataCell(Text('')),
                                                    DataCell(Text('No results found', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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

                    if (_searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              depth: 3,
                              color: Colors.white,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(25),
                              ),
                              lightSource: LightSource.topLeft,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // 👈 prevents full width
                                children: [
                                  Text(
                                    'Grand Total Cost (${_searchController.text}): ₱${_grandTotalCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF01579B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                              SizedBox(
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
    final headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.white);

    return <DataColumn>[
      DataColumn(label: Text('Item Code', style: headerStyle)), // itemCode
      DataColumn(label: Text('Brand', style: headerStyle)), // brand
      DataColumn(label: Text('Description', style: headerStyle)), // productDescription
      DataColumn(label: Text('Pack Size', style: headerStyle)), // lotSerialNumber
      DataColumn(label: Text('Quantity', style: headerStyle)), // orderDate
      DataColumn(label: Text('Unit Cost', style: headerStyle,)), // drSIReferenceNum
      DataColumn(label: Text('Total Cost', style: headerStyle)), // purchaseOrderFile
      DataColumn(label: Text('PO/PI Reference', style: headerStyle)), // suppliersPackingList
      DataColumn(label: Text('', style: headerStyle)), // suppliersPackingList
    ];
  }
    List<DataRow> _buildDataRows(DateFormat formatter, int endIndex, double screenWidth) {
    int counter = 0;
    final bool showAll = _rowsPerPage == _showAllValue;
    final recordsToShow = showAll ? _displayOrders : _displayOrders.sublist(_startIndex, endIndex);

    return recordsToShow.map<DataRow>((order) {
      final matchedBrand = _availableBrands.firstWhere(
        (b) => b['id'] == order.brandId,
        orElse: () => {'brand_name': ''},
      );

      final brandName = matchedBrand['name'] ?? '';

      final isSelected = _selectedOrders.contains(order);
      final rowColor = counter.isEven ? const Color.fromRGBO(241, 245, 255, 1) : const Color.fromRGBO(230, 240, 255, 1);
      counter++;

      return DataRow(
        selected: isSelected,
        onSelectChanged: (bool? selected) => _toggleOrderSelection(order),
        color: WidgetStateProperty.all(rowColor),
        cells: [
          DataCell(Text(order.itemCode ?? '')),
          DataCell(Text(brandName)),
          DataCell(Text(order.productDescription, overflow: TextOverflow.ellipsis)),
          DataCell(Text(order.packSize.toString())),
          DataCell(Text(order.quantity.toString())),
          DataCell(Text(order.unitCost.toStringAsFixed(2))),
          DataCell(Text(order.totalCost.toStringAsFixed(2))),
          DataCell(Text(order.poPireference)),
          DataCell(
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.download),
                  color: Colors.blue[400],
                  tooltip: 'Download Purchase Order',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Download Purchase Order'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Choose a format to save the file:'),
                              const SizedBox(height: 16),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                                ),
                                child: const Text('Save as DOCX'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  _generateAndSaveDOCX(order, brandName);
                                },
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                                ),
                                child: const Text('Save as PDF'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  _generateAndSavePDF(order, brandName);
                                },
                              ),
                            ],
                          ),
                          
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
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