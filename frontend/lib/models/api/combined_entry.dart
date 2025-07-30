import 'dart:typed_data';

import 'package:frontend/models/api/purchase_order.dart';
import 'package:frontend/models/api/transaction_entry.dart';

class CombinedEntry {
  final String brand;
  final String productDescription;
  final String lotSerialNumber;
  final double cost;
  final int quantity;
  
  final String reference;
  final DateTime transactionDate;
  final String stockLocation;
  final DateTime expiryDate;
  
  final Uint8List? purchaseOrderFile;
  final Uint8List? suppliersPackingList;
  final Uint8List? inventoryOfDeliveredItems;

  CombinedEntry({
    required this.brand,
    required this.productDescription,
    required this.lotSerialNumber,
    required this.cost,
    required this.quantity,
    required this.reference,
    required this.transactionDate,
    required this.stockLocation,
    required this.expiryDate,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    this.inventoryOfDeliveredItems,
  });

  factory CombinedEntry.fromJson(Map<String, dynamic> json) {
    return CombinedEntry(
      brand: json['brand'] as String,
      productDescription: json['productDescription'] as String,
      lotSerialNumber: json['lotSerialNumber'] as String,
      cost: json['cost'] as double,
      quantity: json['quantity'] as int,
      reference: json['reference'] as String? ?? 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      transactionDate: DateTime.parse(json['transactionDate'] as String? ?? DateTime.now().toIso8601String()),
      stockLocation: json['stockLocation'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      purchaseOrderFile: json['purchaseOrderFile'] != null 
          ? Uint8List.fromList(List<int>.from(json['purchaseOrderFile']))
          : null,
      suppliersPackingList: json['suppliersPackingList'] != null
          ? Uint8List.fromList(List<int>.from(json['suppliersPackingList']))
          : null,
      inventoryOfDeliveredItems: json['inventoryOfDeliveredItems'] != null
          ? Uint8List.fromList(List<int>.from(json['inventoryOfDeliveredItems']))
          : null,
    );
  }

  TransactionEntry toTransactionEntry() => TransactionEntry(
    reference: reference,
    transactionDate: transactionDate,
    brand: brand,
    itemDescription: productDescription,
    lotNumber: lotSerialNumber,
    expiryDate: expiryDate,
    cost: cost,
    quantity: quantity,
    stockLocation: stockLocation,
  );

  PurchaseOrder toPurchaseOrder() => PurchaseOrder(
    itemCode: '',
    brand: brand,
    productDescription: productDescription,
    lotSerialNumber: lotSerialNumber,
    purchaseOrderFile: purchaseOrderFile,
    suppliersPackingList: suppliersPackingList,
    inventoryOfDeliveredItems: inventoryOfDeliveredItems,
    orderDate: transactionDate,
    drSIReferenceNum: reference,
  );
}