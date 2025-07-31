import 'dart:typed_data';

class PurchaseOrder {
  String itemCode;
  String brand;
  String productDescription;
  String lotSerialNumber;
  String? purchaseOrderFile;
  String? suppliersPackingList;
  String? inventoryOfDeliveredItems;
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

  bool get hasPurchaseOrderFile => purchaseOrderFile != null && purchaseOrderFile!.isNotEmpty;
  bool get hasSuppliersPackingList => suppliersPackingList != null && suppliersPackingList!.isNotEmpty;
  bool get hasInventoryOfDeliveredItems => inventoryOfDeliveredItems != null && inventoryOfDeliveredItems!.isNotEmpty;
  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    try {
      return PurchaseOrder(
        itemCode: json['itemCode'] ?? 'Unknown Code',
        brand: json['brand'] ?? 'No Brand Provided',
        productDescription: json['productDescription'] ?? 'No Description',
        lotSerialNumber: json['lotSerialNumber'] ?? 'N/A',
        purchaseOrderFile: json['purchaseOrderFile'],
        suppliersPackingList: json['suppliersPackingList'],
        inventoryOfDeliveredItems: json['inventoryOfDeliveredItems'],
        orderDate: DateTime.parse(json['orderDate']),
        drSIReferenceNum: json['drSIReferenceNum'] ?? 'N/A',
      );
    } catch (e) {
      throw DataParsingException('Error parsing PurchaseOrder from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'brand': brand,
    'productDescription': productDescription,
    'lotSerialNumber': lotSerialNumber,
    'purchaseOrderFile': purchaseOrderFile,
    'suppliersPackingList': suppliersPackingList,
    'inventoryOfDeliveredItems': inventoryOfDeliveredItems,
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