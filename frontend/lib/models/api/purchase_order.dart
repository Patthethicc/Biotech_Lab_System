import 'dart:typed_data';

class PurchaseOrder {
  String itemCode;
  String brand;
  String productDescription;
  String lotSerialNumber;
  Uint8List? purchaseOrderFile;
  Uint8List? suppliersPackingList;
  Uint8List? inventoryOfDeliveredItems;
  DateTime orderDate;
  String drSIReferenceNum;

  PurchaseOrder({
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.lotSerialNumber,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    this.inventoryOfDeliveredItems,
    required this.orderDate,
    required this.drSIReferenceNum,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    try {
      return PurchaseOrder(
        itemCode: json['itemCode'],
        brand: json['brand'],
        productDescription: json['productDescription'],
        lotSerialNumber: json['lotSerialNumber'],
        purchaseOrderFile: json['purchaseOrderFile'] != null 
            ? Uint8List.fromList(List<int>.from(json['purchaseOrderFile']))
            : null,
        suppliersPackingList: json['suppliersPackingList'] != null
            ? Uint8List.fromList(List<int>.from(json['suppliersPackingList']))
            : null,
        inventoryOfDeliveredItems: json['inventoryOfDeliveredItems'] != null
            ? Uint8List.fromList(List<int>.from(json['inventoryOfDeliveredItems']))
            : null,
        orderDate: DateTime.parse(json['orderDate']),
        drSIReferenceNum: json['drSIReferenceNum'],
      );
    } catch (e) {
      throw DataParsingException('Error parsing PurchaseOrder from JSON: $e');
    }
    return PurchaseOrder(
      purchaseOrderCode: json['purchaseOrderCode'],
      itemCode: json['itemCode'],
      purchaseOrderFile: json['purchaseOrderFile'],
      suppliersPackingList: json['suppliersPackingList'],
      quantityPurchased: json['quantityPurchased'],
      orderDate: DateTime.parse(json['orderDate']),
      expectedDeliveryDate: DateTime.parse(json['expectedDeliveryDate']),
      cost: (json['cost'] as num).toDouble(),
      addedBy: json['addedBy'],
      dateTimeAdded: json['dateTimeAdded'] != null ? DateTime.parse(json['dateTimeAdded']) : null,
      hasPurchaseOrderFile: json['hasPurchaseOrderFile'] ?? false,
      hasSuppliersPackingList: json['hasSuppliersPackingList'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'brand': brand,
    'productDescription': productDescription,
    'lotSerialNumber': lotSerialNumber,
    'purchaseOrderFile': purchaseOrderFile?.toList(),
    'suppliersPackingList': suppliersPackingList?.toList(),
    'inventoryOfDeliveredItems': inventoryOfDeliveredItems?.toList(),
    'orderDate': orderDate.toIso8601String(),
    'drSIReferenceNum': drSIReferenceNum,
  };
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => 'DataParsingException: $message';

}