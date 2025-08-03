import 'dart:typed_data';
import 'dart:convert';

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
  
  String? purchaseOrderFileName;
  String? suppliersPackingListName;
  String? inventoryOfDeliveredItemsName;
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
    this.purchaseOrderFileName,
    this.suppliersPackingListName,
    this.inventoryOfDeliveredItemsName,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    this.inventoryOfDeliveredItems,
  });

  factory CombinedEntry.fromJson(Map<String, dynamic> json) {
    return CombinedEntry(
      brand: json['brand'].toString().trim(),
      productDescription: json['productDescription'] as String,
      lotSerialNumber: json['lotSerialNumber'] as String,
      cost: json['cost'] as double,
      quantity: json['quantity'] as int,
      reference: json['drSIReferenceNum'] as String? ?? 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      transactionDate: DateTime.parse(json['transactionDate'] as String? ?? DateTime.now().toIso8601String()),
      stockLocation: json['stockLocation'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      purchaseOrderFileName: json['purchaseOrderFileName'] ?? 'No File Name',
      suppliersPackingListName: json['suppliersPackingListName'] ?? 'No File Name',
      inventoryOfDeliveredItemsName: json['inventoryOfDeliveredItemsName'] ?? 'No File Name',
      purchaseOrderFile: json['purchaseOrderFile'] != null 
          ? base64Decode(json['purchaseOrderFile'] as String) 
          : null,
      suppliersPackingList: json['suppliersPackingList'] != null
          ? base64Decode(json['suppliersPackingList'] as String)
          : null,
      inventoryOfDeliveredItems: json['inventoryOfDeliveredItems'] != null
          ? base64Decode(json['inventoryOfDeliveredItems'] as String)
          : null,
    );
  }

   Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'drSIReferenceNum': reference,
      'transactionDate': transactionDate.toIso8601String(),
      'brand': brand,
      'productDescription': productDescription,
      'lotSerialNumber': lotSerialNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'cost': cost,
      'quantity': quantity,
      'stockLocation': stockLocation,
      'purchaseOrderFileName': purchaseOrderFileName,
      'suppliersPackingListName': suppliersPackingListName,
      'inventoryOfDeliveredItemsName': inventoryOfDeliveredItemsName,
    };

    // Handle file bytes - convert to base64 if not null
    if (purchaseOrderFile != null) {
      json['purchaseOrderFile'] = base64Encode(purchaseOrderFile!);
    }
    if (suppliersPackingList != null) {
      json['suppliersPackingList'] = base64Encode(suppliersPackingList!);
    }
    if (inventoryOfDeliveredItems != null) {
      json['inventoryOfDeliveredItems'] = base64Encode(inventoryOfDeliveredItems!);
    }

    return json;
  }
}