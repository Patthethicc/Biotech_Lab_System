import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
    purchaseOrderCode: json['purchaseOrderCode'],
    purchaseOrderFile: json['purchaseOrderFile'],
    suppliersPackingList: json['suppliersPackingList'],
    quantityPurchased: json['quantityPurchased'],
    orderDate: DateTime.parse(json['orderDate']),
    expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
    cost: (json['cost'] as num).toDouble(),
  );

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
    final response = await http.get(Uri.parse('$baseUrl/getPOs'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => PurchaseOrder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load purchase orders');
    }
  }

  Future<void> addPurchaseOrder(PurchaseOrder po) async {
    await http.post(
      Uri.parse('$baseUrl/addPO'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(po.toJson()),
    );
  }

  Future<void> updatePurchaseOrder(PurchaseOrder po) async {
    await http.put(
      Uri.parse('$baseUrl/updatePO'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(po.toJson()),
    );
  }

  Future<void> deletePurchaseOrder(String purchaseOrderCode) async {
    await http.delete(
      Uri.parse('$baseUrl/deletePO/$purchaseOrderCode'),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  List<PurchaseOrder> orders = [
    PurchaseOrder(
      purchaseOrderCode: 'PO-2024-201',
      purchaseOrderFile: null,
      suppliersPackingList: null,
      quantityPurchased: 150,
      orderDate: DateTime(2024, 6, 1),
      expectedDeliveryDate: DateTime(2024, 6, 10),
      cost: 45000,
    ),
    PurchaseOrder(
      purchaseOrderCode: 'PO-2024-202',
      purchaseOrderFile: null,
      suppliersPackingList: null,
      quantityPurchased: 75,
      orderDate: DateTime(2024, 6, 5),
      expectedDeliveryDate: DateTime(2024, 6, 15),
      cost: 12000,
    ),
    PurchaseOrder(
      purchaseOrderCode: 'PO-2024-203',
      purchaseOrderFile: null,
      suppliersPackingList: null,
      quantityPurchased: 40,
      orderDate: DateTime(2024, 6, 10),
      expectedDeliveryDate: DateTime(2024, 6, 20),
      cost: 80000,
    ),
  ];
  bool isLoading = false;
  bool hasError = false;

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
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order Code',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: fileUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Order File',
                        prefixIcon: Icon(Icons.attach_file),
                      ),
                      validator: (value) => null, 
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: supplierPackingListController,
                      decoration: const InputDecoration(
                        labelText: "Supplier's Packing List",
                        prefixIcon: Icon(Icons.table_chart),
                      ),
                      validator: (value) => null, 
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity Purchased',
                        prefixIcon: Icon(Icons.shopping_cart),
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
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          orderDate = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Order Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(orderDate != null
                            ? DateFormat('yyyy-MM-dd').format(orderDate!)
                            : ''),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          deliveryDate = picked;
                          (context as Element).markNeedsBuild();
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Expected Delivery Date',
                          prefixIcon: Icon(Icons.delivery_dining),
                        ),
                        child: Text(deliveryDate != null
                            ? DateFormat('yyyy-MM-dd').format(deliveryDate!)
                            : ''),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                        prefixIcon: Icon(Icons.attach_money),
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
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    orderDate != null &&
                    deliveryDate != null) {
                  setState(() {
                    orders.add(PurchaseOrder(
                      purchaseOrderCode: codeController.text,
                      purchaseOrderFile: fileUrlController.text.isEmpty ? null : fileUrlController.text,
                      suppliersPackingList: supplierPackingListController.text.isEmpty ? null : supplierPackingListController.text,
                      quantityPurchased: int.parse(quantityController.text),
                      orderDate: orderDate!,
                      expectedDeliveryDate: deliveryDate!,
                      cost: double.parse(costController.text),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editCellDialog(PurchaseOrder order, String field) {
    final controller = TextEditingController(
      text: field == 'orderDate' || field == 'expectedDeliveryDate'
          ? DateFormat('yyyy-MM-dd').format(
              field == 'orderDate' ? order.orderDate : order.expectedDeliveryDate)
          : order.toJson()[field]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${_getFieldLabel(field)}'),
          content: field == 'orderDate' || field == 'expectedDeliveryDate'
              ? InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: field == 'orderDate' ? order.orderDate : order.expectedDeliveryDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Pick Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(controller.text),
                  ),
                )
              : TextFormField(
                  controller: controller,
                  keyboardType: field == 'quantityPurchased' || field == 'cost'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(labelText: _getFieldLabel(field)),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  switch (field) {
                    case 'code':
                      order.purchaseOrderCode = controller.text;
                      break;
                    case 'fileUrl':
                      order.purchaseOrderFile = controller.text;
                      break;
                    case 'supplierPackingList':
                      order.suppliersPackingList = controller.text;
                      break;
                    case 'quantityPurchased':
                      order.quantityPurchased = int.tryParse(controller.text) ?? order.quantityPurchased;
                      break;
                    case 'orderDate':
                      order.orderDate = DateFormat('yyyy-MM-dd').parse(controller.text);
                      break;
                    case 'expectedDeliveryDate':
                      order.expectedDeliveryDate = DateFormat('yyyy-MM-dd').parse(controller.text);
                      break;
                    case 'cost':
                      order.cost = double.tryParse(controller.text) ?? order.cost;
                      break;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'code': return 'Purchase Order Code';
      case 'fileUrl': return 'Purchase Order File';
      case 'supplierPackingList': return "Supplier's Packing List";
      case 'quantityPurchased': return 'Quantity Purchased';
      case 'orderDate': return 'Order Date';
      case 'expectedDeliveryDate': return 'Expected Delivery Date';
      case 'cost': return 'Cost';
      default: return field;
    }
  }

  void _deleteOrder(PurchaseOrder order) {
    setState(() {
      orders.remove(order);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return const Center(child: Text('Failed to load purchase orders.'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Purchase Order'),
                onPressed: _showAddDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                  columns: const [
                    DataColumn(label: Text('Purchase Order Code')),
                    DataColumn(label: Text('Purchase Order File')),
                    DataColumn(label: Text("Supplier's Packing List")),
                    DataColumn(label: Text('Quantity Purchased')),
                    DataColumn(label: Text('Order Date')),
                    DataColumn(label: Text('Expected Delivery Date')),
                    DataColumn(label: Text('Cost')),
                    DataColumn(label: Text('')),
                  ],
                  rows: orders.map((order) {
                    return DataRow(cells: [
                      DataCell(
                        Text(order.purchaseOrderCode),
                        onTap: () => _editCellDialog(order, 'code'),
                      ),
                      DataCell(
                        order.purchaseOrderFile != null
                          ? GestureDetector(
                              child: const Text('View'),
                              onTap: () => _editCellDialog(order, 'fileUrl'),
                            )
                          : GestureDetector(
                              child: const Text('N/A'),
                              onTap: () => _editCellDialog(order, 'fileUrl'),
                            ),
                      ),
                      DataCell(
                        Text(order.suppliersPackingList ?? 'N/A'),
                        onTap: () => _editCellDialog(order, 'supplierPackingList'),
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
                        Text('₱${order.cost.toStringAsFixed(2)}'),
                        onTap: () => _editCellDialog(order, 'cost'),
                      ),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(order),
                      )),
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