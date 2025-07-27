import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Exception for network errors
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

// Exception for data parsing errors
class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => 'DataParsingException: $message';
}

class PurchaseOrder {
  String purchaseOrderCode;
  String? purchaseOrderFile;
  String? suppliersPackingList;
  int quantityPurchased;
  DateTime orderDate;
  DateTime expectedDeliveryDate;
  double cost;

  PurchaseOrder({
    required this.purchaseOrderCode,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    required this.quantityPurchased,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.cost,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    try {
      return PurchaseOrder(
        purchaseOrderCode: json['purchaseOrderCode'],
        purchaseOrderFile: json['purchaseOrderFile'],
        suppliersPackingList: json['suppliersPackingList'],
        quantityPurchased: json['quantityPurchased'],
        orderDate: DateTime.parse(json['orderDate']),
        expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
        cost: (json['cost'] as num).toDouble(),
      );
    } catch (e) {
      throw DataParsingException('Error parsing PurchaseOrder from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    'purchaseOrderCode': purchaseOrderCode,
    'purchaseOrderFile': purchaseOrderFile,
    'suppliersPackingList': suppliersPackingList,
    'quantityPurchased': quantityPurchased,
    'orderDate': orderDate.toIso8601String(),
    'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
    'cost': cost,
  };
}

class PurchaseOrderService {
  static const String baseUrl = 'http://localhost:8080/po/v1';

  Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getPOs'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => PurchaseOrder.fromJson(json)).toList();
      } else {
        throw NetworkException('Failed to load purchase orders: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw DataParsingException('Invalid JSON response: $e');
      }
      rethrow; // Rethrow other exceptions like NetworkException or SocketException
    }
  }

  Future<void> addPurchaseOrder(PurchaseOrder po) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addPO'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(po.toJson()),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw NetworkException('Failed to add purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePurchaseOrder(PurchaseOrder po) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updatePO'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(po.toJson()),
      );
      if (response.statusCode != 200) {
        throw NetworkException('Failed to update purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePurchaseOrder(String purchaseOrderCode) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deletePO/$purchaseOrderCode'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw NetworkException('Failed to delete purchase order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  List<PurchaseOrder> orders = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  final PurchaseOrderService _poService = PurchaseOrderService();

  @override
  void initState() {
    super.initState();
    _fetchPurchaseOrders();
  }

  Future<void> _fetchPurchaseOrders() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });
    try {
      final fetchedOrders = await _poService.fetchPurchaseOrders();
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error fetching purchase orders: $e';
      });
      _showSnackBar(errorMessage, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showAddDialog() {
    final _formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final fileUrlController = TextEditingController();
    final supplierPackingListController = TextEditingController();
    final quantityController = TextEditingController();
    final costController = TextEditingController();
    DateTime? orderDate;
    DateTime? deliveryDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Purchase Order'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure content fits
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order Code',
                        prefixIcon: Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: fileUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order File URL (Optional)',
                        prefixIcon: Icon(Icons.attach_file),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: supplierPackingListController,
                      decoration: const InputDecoration(
                        labelText: "Supplier's Packing List URL (Optional)",
                        prefixIcon: Icon(Icons.table_chart),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity Purchased',
                        prefixIcon: Icon(Icons.shopping_cart),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setStateSB) {
                        return InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: orderDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateSB(() {
                                orderDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Order Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              errorText: orderDate == null ? 'Required' : null,
                            ),
                            child: Text(orderDate != null
                                ? DateFormat('yyyy-MM-dd').format(orderDate!)
                                : 'Select Order Date'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setStateSB) {
                        return InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: deliveryDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateSB(() {
                                deliveryDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Expected Delivery Date',
                              prefixIcon: const Icon(Icons.delivery_dining),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              errorText: deliveryDate == null ? 'Required' : null,
                            ),
                            child: Text(deliveryDate != null
                                ? DateFormat('yyyy-MM-dd').format(deliveryDate!)
                                : 'Select Expected Delivery Date'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Enter a valid cost';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    orderDate != null &&
                    deliveryDate != null) {
                  final newPo = PurchaseOrder(
                    purchaseOrderCode: codeController.text,
                    purchaseOrderFile: fileUrlController.text.isEmpty ? null : fileUrlController.text,
                    suppliersPackingList: supplierPackingListController.text.isEmpty ? null : supplierPackingListController.text,
                    quantityPurchased: int.parse(quantityController.text),
                    orderDate: orderDate!,
                    expectedDeliveryDate: deliveryDate!,
                    cost: double.parse(costController.text),
                  );

                  try {
                    await _poService.addPurchaseOrder(newPo);
                    _showSnackBar('Purchase Order added successfully!');
                    Navigator.pop(context);
                    _fetchPurchaseOrders(); // Refresh the list
                  } catch (e) {
                    _showSnackBar('Failed to add purchase order: $e', isError: true);
                  }
                } else if (orderDate == null || deliveryDate == null) {
                  _showSnackBar('Please select both order date and expected delivery date.', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editCellDialog(PurchaseOrder order, String field) {
    final TextEditingController controller = TextEditingController();
    DateTime? selectedDate;

    // Initialize controller based on field type
    if (field == 'orderDate' || field == 'expectedDeliveryDate') {
      selectedDate = field == 'orderDate' ? order.orderDate : order.expectedDeliveryDate;
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    } else {
      controller.text = order.toJson()[field]?.toString() ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${_getFieldLabel(field)}'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateSB) {
              return field == 'orderDate' || field == 'expectedDeliveryDate'
                  ? InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setStateSB(() {
                            selectedDate = picked;
                            controller.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Pick Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Text(controller.text.isEmpty ? 'Select Date' : controller.text),
                      ),
                    )
                  : TextFormField(
                      controller: controller,
                      keyboardType: field == 'quantityPurchased' || field == 'cost'
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: _getFieldLabel(field),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (field == 'quantityPurchased' && (value == null || int.tryParse(value) == null || int.parse(value) <= 0)) {
                          return 'Enter a valid quantity';
                        }
                        if (field == 'cost' && (value == null || double.tryParse(value) == null || double.parse(value) < 0)) {
                          return 'Enter a valid cost';
                        }
                        return null;
                      },
                    );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Create a temporary PO object to hold potential updates
                PurchaseOrder updatedPo = PurchaseOrder(
                  purchaseOrderCode: order.purchaseOrderCode,
                  purchaseOrderFile: order.purchaseOrderFile,
                  suppliersPackingList: order.suppliersPackingList,
                  quantityPurchased: order.quantityPurchased,
                  orderDate: order.orderDate,
                  expectedDeliveryDate: order.expectedDeliveryDate,
                  cost: order.cost,
                );

                try {
                  switch (field) {
                    case 'purchaseOrderCode':
                      updatedPo.purchaseOrderCode = controller.text;
                      break;
                    case 'purchaseOrderFile':
                      updatedPo.purchaseOrderFile = controller.text.isEmpty ? null : controller.text;
                      break;
                    case 'suppliersPackingList':
                      updatedPo.suppliersPackingList = controller.text.isEmpty ? null : controller.text;
                      break;
                    case 'quantityPurchased':
                      updatedPo.quantityPurchased = int.tryParse(controller.text) ?? updatedPo.quantityPurchased;
                      break;
                    case 'orderDate':
                      if (selectedDate != null) updatedPo.orderDate = selectedDate!;
                      break;
                    case 'expectedDeliveryDate':
                      if (selectedDate != null) updatedPo.expectedDeliveryDate = selectedDate!;
                      break;
                    case 'cost':
                      updatedPo.cost = double.tryParse(controller.text) ?? updatedPo.cost;
                      break;
                  }

                  await _poService.updatePurchaseOrder(updatedPo);
                  _showSnackBar('Purchase Order updated successfully!');
                  Navigator.pop(context);
                  _fetchPurchaseOrders(); // Refresh the list
                } catch (e) {
                  _showSnackBar('Failed to update purchase order: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'purchaseOrderCode': return 'Purchase Order Code';
      case 'purchaseOrderFile': return 'Purchase Order File';
      case 'suppliersPackingList': return "Supplier's Packing List";
      case 'quantityPurchased': return 'Quantity Purchased';
      case 'orderDate': return 'Order Date';
      case 'expectedDeliveryDate': return 'Expected Delivery Date';
      case 'cost': return 'Cost';
      default: return field;
    }
  }

  void _deleteOrder(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Purchase Order'),
          content: Text('Are you sure you want to delete PO: ${order.purchaseOrderCode}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _poService.deletePurchaseOrder(order.purchaseOrderCode);
                  _showSnackBar('Purchase Order deleted successfully!');
                  Navigator.pop(context);
                  _fetchPurchaseOrders(); // Refresh the list
                } catch (e) {
                  _showSnackBar('Failed to delete purchase order: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.blueGrey,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Purchase Orders Management',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add New Purchase Order'),
                  onPressed: _showAddDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 50),
                              const SizedBox(height: 10),
                              Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _fetchPurchaseOrders,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : orders.isEmpty
                          ? const Center(
                              child: Text(
                                'No purchase orders found. Click "Add New Purchase Order" to add one.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : Expanded(
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    columnSpacing: 24,
                                    dataRowHeight: 60,
                                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                        return Theme.of(context).primaryColor.withOpacity(0.1);
                                      },
                                    ),
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                      top: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Purchase Order Code', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Purchase Order File', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Supplier's Packing List", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Quantity Purchased', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Order Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Expected Delivery Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: orders.map((order) {
                                      return DataRow(cells: [
                                        DataCell(
                                          Text(order.purchaseOrderCode),
                                          onTap: () => _editCellDialog(order, 'purchaseOrderCode'),
                                        ),
                                        DataCell(
                                          order.purchaseOrderFile != null && order.purchaseOrderFile!.isNotEmpty
                                              ? GestureDetector(
                                                  child: const Text('View File', style: TextStyle(color: Colors.blue)),
                                                  onTap: () => _editCellDialog(order, 'purchaseOrderFile'),
                                                )
                                              : GestureDetector(
                                                  child: const Text('N/A (Add File)', style: TextStyle(color: Colors.grey)),
                                                  onTap: () => _editCellDialog(order, 'purchaseOrderFile'),
                                                ),
                                        ),
                                        DataCell(
                                          order.suppliersPackingList != null && order.suppliersPackingList!.isNotEmpty
                                              ? GestureDetector(
                                                  child: const Text('View List', style: TextStyle(color: Colors.blue)),
                                                  onTap: () => _editCellDialog(order, 'suppliersPackingList'),
                                                )
                                              : GestureDetector(
                                                  child: const Text('N/A (Add List)', style: TextStyle(color: Colors.grey)),
                                                  onTap: () => _editCellDialog(order, 'suppliersPackingList'),
                                                ),
                                        ),
                                        DataCell(
                                          Text(order.quantityPurchased.toString()),
                                          onTap: () => _editCellDialog(order, 'quantityPurchased'),
                                        ),
                                        DataCell(
                                          Text(DateFormat('yyyy-MM-dd').format(order.orderDate)),
                                          onTap: () => _editCellDialog(order, 'orderDate'),
                                        ),
                                        DataCell(
                                          Text(DateFormat('yyyy-MM-dd').format(order.expectedDeliveryDate)),
                                          onTap: () => _editCellDialog(order, 'expectedDeliveryDate'),
                                        ),
                                        DataCell(
                                          Text(NumberFormat.currency(locale: 'en_PH', symbol: '₱').format(order.cost)),
                                          onTap: () => _editCellDialog(order, 'cost'),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                onPressed: () {
                                                  // This is handled by onTap on DataCell
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _deleteOrder(order),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
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