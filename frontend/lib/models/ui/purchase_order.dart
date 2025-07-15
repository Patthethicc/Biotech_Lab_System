import 'package:flutter/material.dart';

class PurchaseOrder {
  String code;
  String item;
  int quantityOrdered;
  String orderDate;
  String expectedDeliveryDate;
  String? purchaseOrderFile;
  String? suppliersPackingList;
  double cost;

  PurchaseOrder({
    required this.code,
    required this.item,
    required this.quantityOrdered,
    required this.orderDate,
    required this.expectedDeliveryDate,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    required this.cost,
  });
}

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final List<PurchaseOrder> _orders = [
    PurchaseOrder(
      code: 'PO-2024-201',
      item: 'Disposable Gloves',
      quantityOrdered: 150,
      orderDate: '2024-06-01',
      expectedDeliveryDate: '2024-06-10',
      purchaseOrderFile: 'packing_list_acme.pdf',
      cost: 45000.00,
    ),
    PurchaseOrder(
      code: 'PO-2024-202',
      item: 'Microscope Slides',
      quantityOrdered: 75,
      orderDate: '2024-06-05',
      expectedDeliveryDate: '2024-06-15',
      purchaseOrderFile: 'packing_list_labtech.pdf',
      cost: 12000.00,
    ),
    PurchaseOrder(
      code: 'PO-2024-203',
      item: 'Chemical Reagents',
      quantityOrdered: 40,
      orderDate: '2024-06-10',
      expectedDeliveryDate: '2024-06-20',
      purchaseOrderFile: null,
      cost: 80000.00,
    ),
  ];

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _quantityOrderedController = TextEditingController();
  final TextEditingController _orderDateController = TextEditingController();
  final TextEditingController _expectedDeliveryDateController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _purchaseOrderFileController = TextEditingController();
  final TextEditingController _suppliersPackingListController = TextEditingController();

  final ScrollController _horizontalScrollController = ScrollController();

  final List<String> _itemOptions = [
    'Disposable Gloves',
    'Microscope Slides',
    'Chemical Reagents',
    'PCR Tubes',
    'Lab Disinfectant',
  ];

  void _deleteOrder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Order'),
        content: Text('Are you sure you want to delete ${_orders[index].code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _orders.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewOrderFile(String? file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(file != null ? 'Viewing $file' : 'No file available')),
    );
  }

  void _showAddOrderDialog() {
    _codeController.clear();
    _quantityOrderedController.clear();
    _orderDateController.clear();
    _expectedDeliveryDateController.clear();
    _itemController.clear();
    _costController.clear();
    _purchaseOrderFileController.clear();
    _suppliersPackingListController.clear();

    String? selectedItem;
    DateTime? selectedOrderDate;
    DateTime? selectedExpectedDeliveryDate;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Purchase Order'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _purchaseOrderFileController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Order File',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_file),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _suppliersPackingListController,
                    decoration: const InputDecoration(
                      labelText: "Supplier's Packing List",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list_alt),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityOrderedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity Purchased',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_cart),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedOrderDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        selectedOrderDate = picked;
                        _orderDateController.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: _orderDateController,
                        decoration: const InputDecoration(
                          labelText: 'Order Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedExpectedDeliveryDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        selectedExpectedDeliveryDate = picked;
                        _expectedDeliveryDateController.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: _expectedDeliveryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expected Delivery Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.delivery_dining),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedItem,
                    items: _itemOptions.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedItem = value;
                      _itemController.text = value ?? '';
                    },
                    decoration: const InputDecoration(
                      labelText: 'Items Purchased',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _costController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
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
                List<String> errors = [];
                if (_codeController.text.trim().isEmpty) {
                  errors.add('Purchase Order Code is required.');
                }
                if (_quantityOrderedController.text.trim().isEmpty ||
                    int.tryParse(_quantityOrderedController.text) == null ||
                    int.parse(_quantityOrderedController.text) <= 0) {
                  errors.add('Quantity Purchased must be a valid positive number.');
                }
                if (_orderDateController.text.trim().isEmpty) {
                  errors.add('Order Date is required.');
                }
                if (_expectedDeliveryDateController.text.trim().isEmpty) {
                  errors.add('Expected Delivery Date is required.');
                }
                if (_itemController.text.trim().isEmpty) {
                  errors.add('Items Purchased is required.');
                }
                if (_costController.text.trim().isEmpty ||
                    double.tryParse(_costController.text) == null ||
                    double.parse(_costController.text) <= 0) {
                  errors.add('Cost must be a valid positive number.');
                }
                if (errors.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Input Errors'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.red))).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                setState(() {
                  _orders.add(PurchaseOrder(
                    code: _codeController.text,
                    purchaseOrderFile: _purchaseOrderFileController.text,
                    suppliersPackingList: _suppliersPackingListController.text,
                    quantityOrdered: int.parse(_quantityOrderedController.text),
                    orderDate: _orderDateController.text,
                    expectedDeliveryDate: _expectedDeliveryDateController.text,
                    item: _itemController.text,
                    cost: double.parse(_costController.text),
                  ));
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editCell(int rowIndex, String field) async {
    final order = _orders[rowIndex];
    TextEditingController controller = TextEditingController();

    Widget fieldWidget;

    switch (field) {
      case 'orderDate':
        controller.text = order.orderDate;
        fieldWidget = InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(order.orderDate) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.text =
                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            }
          },
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Order Date'),
            ),
          ),
        );
        break;
      case 'expectedDeliveryDate':
        controller.text = order.expectedDeliveryDate;
        fieldWidget = InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(order.expectedDeliveryDate) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.text =
                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            }
          },
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Expected Delivery Date'),
            ),
          ),
        );
        break;
      case 'item':
        String? selectedItem = order.item;
        fieldWidget = DropdownButtonFormField<String>(
          value: selectedItem,
          items: _itemOptions.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            selectedItem = value;
            controller.text = value ?? '';
          },
          decoration: const InputDecoration(labelText: 'Items Purchased'),
        );
        break;
      default:
        switch (field) {
          case 'code': controller.text = order.code; break;
          case 'quantityOrdered': controller.text = order.quantityOrdered.toString(); break;
          case 'cost': controller.text = order.cost.toString(); break;
          case 'purchaseOrderFile':
            controller.text = order.purchaseOrderFile ?? '';
            fieldWidget = TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Purchase Order File'),
            );
            break;
          case 'suppliersPackingList':
            controller.text = order.suppliersPackingList ?? '';
            fieldWidget = TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Supplier's Packing List"),
            );
            break;
        }
        fieldWidget = TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New value'),
        );
        break;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_getFieldLabel(field)}'),
        content: fieldWidget,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              List<String> errors = [];
              String value = controller.text.trim();
              switch (field) {
                case 'code':
                  if (value.isEmpty) errors.add('Purchase Order Code is required.');
                  break;
                case 'quantityOrdered':
                  if (value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    errors.add('Quantity Purchased must be a valid positive number.');
                  }
                  break;
                case 'orderDate':
                  if (value.isEmpty) errors.add('Order Date is required.');
                  break;
                case 'expectedDeliveryDate':
                  if (value.isEmpty) errors.add('Expected Delivery Date is required.');
                  break;
                case 'item':
                  if (value.isEmpty) errors.add('Items Purchased is required.');
                  break;
                case 'cost':
                  if (value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    errors.add('Cost must be a valid positive number.');
                  }
                  break;
              }
              if (errors.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Input Errors'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.red))).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                return;
              }
              setState(() {
                switch (field) {
                  case 'item': order.item = controller.text; break;
                  case 'code': order.code = controller.text; break;
                  case 'quantityOrdered': order.quantityOrdered = int.parse(controller.text); break;
                  case 'orderDate': order.orderDate = controller.text; break;
                  case 'expectedDeliveryDate': order.expectedDeliveryDate = controller.text; break;
                  case 'cost': order.cost = double.parse(controller.text); break;
                  case 'purchaseOrderFile': order.purchaseOrderFile = controller.text.isNotEmpty ? controller.text : null; break;
                  case 'suppliersPackingList': order.suppliersPackingList = controller.text.isNotEmpty ? controller.text : null; break;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'code': return 'Purchase Order Code';
      case 'quantityOrdered': return 'Quantity Purchased';
      case 'orderDate': return 'Order Date';
      case 'expectedDeliveryDate': return 'Expected Delivery Date';
      case 'item': return 'Items Purchased';
      case 'cost': return 'Cost';
      default: return field;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Purchase Order'),
                  onPressed: _showAddOrderDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(
                          color: Colors.blueGrey,
                          width: 1,
                        ),
                        columns: const [
                          DataColumn(label: Text('Purchase Order Code')),
                          DataColumn(label: Text('Purchase Order File')),
                          DataColumn(label: Text("Supplier's Packing List")),
                          DataColumn(label: Text('Quantity Purchased')),
                          DataColumn(label: Text('Order Date')),
                          DataColumn(label: Text('Expected Delivery Date')),
                          DataColumn(label: Text('Items Purchased')),
                          DataColumn(label: Text('Cost')),
                          DataColumn(label: Text(' ')),
                        ],
                        rows: List.generate(_orders.length, (index) {
                          final order = _orders[index];
                          return DataRow(
                            cells: [
                              DataCell(Text(order.code), onTap: () => _editCell(index, 'code')),
                              DataCell(
                                order.purchaseOrderFile != null && order.purchaseOrderFile!.isNotEmpty
                                  ? ElevatedButton(
                                      onPressed: () => _viewOrderFile(order.purchaseOrderFile),
                                      child: const Text('View'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                    )
                                  : const Text('N/A'),
                                onTap: () => _editCell(index, 'purchaseOrderFile'),
                              ),
                              DataCell(Text(order.suppliersPackingList ?? 'N/A'), onTap: () => _editCell(index, 'suppliersPackingList')),
                              DataCell(Text(order.quantityOrdered.toString()), onTap: () => _editCell(index, 'quantityOrdered')),
                              DataCell(Text(order.orderDate), onTap: () => _editCell(index, 'orderDate')),
                              DataCell(Text(order.expectedDeliveryDate), onTap: () => _editCell(index, 'expectedDeliveryDate')),
                              DataCell(Text(order.item), onTap: () => _editCell(index, 'item')),
                              DataCell(Text('₱${order.cost.toStringAsFixed(2)}'), onTap: () => _editCell(index, 'cost')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteOrder(index),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }
}