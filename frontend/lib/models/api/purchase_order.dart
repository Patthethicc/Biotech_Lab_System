import 'dart:typed_data';
import 'dart:convert';

class PurchaseOrder {
  String itemCode;
  String brand;
  String productDescription;
  String lotSerialNumber;
  String? purchaseOrderFileName;
  Uint8List? purchaseOrderFile;
  String? suppliersPackingListName;
  Uint8List? suppliersPackingList;
  String? inventoryOfDeliveredItemsName;
  Uint8List? inventoryOfDeliveredItems;
  DateTime orderDate;
  String drSIReferenceNum;

  PurchaseOrder({
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.lotSerialNumber,
    this.purchaseOrderFileName,
    this.purchaseOrderFile,
    this.suppliersPackingListName,
    this.suppliersPackingList,
    this.inventoryOfDeliveredItemsName,
    this.inventoryOfDeliveredItems,
    required this.orderDate,
    required this.drSIReferenceNum,
  });

  bool get hasPurchaseOrderFile => purchaseOrderFile != null;
  bool get hasSuppliersPackingList => suppliersPackingList != null;
  bool get hasInventoryOfDeliveredItems => inventoryOfDeliveredItems != null;
  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
      return PurchaseOrder(
        itemCode: json['itemCode'] ?? 'Unknown Code',
        brand: json['brand'] ?? 'No Brand Provided',
        productDescription: json['productDescription'] ?? 'No Description',
        lotSerialNumber: json['lotSerialNumber'] ?? 'N/A',
        purchaseOrderFileName: json['purchaseOrderFileName'] ?? 'No File Name',
        purchaseOrderFile: json['purchaseOrderFile'] != null 
          ? base64Decode(json['purchaseOrderFile'] as String) 
          : null,
        suppliersPackingListName: json['suppliersPackingListName'] ?? 'No File Name',
        suppliersPackingList: json['suppliersPackingList'] != null
          ? base64Decode(json['suppliersPackingList'] as String)
          : null,
        inventoryOfDeliveredItemsName: json['inventoryOfDeliveredItemsName'] ?? 'No File Name',
        inventoryOfDeliveredItems: json['inventoryOfDeliveredItems'] != null
          ? base64Decode(json['inventoryOfDeliveredItems'] as String)
          : null,
        orderDate: DateTime.parse(json['orderDate']),
        drSIReferenceNum: json['drSIReferenceNum'] ?? 'N/A',
      );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'itemCode': itemCode,
      'brand': brand,
      'productDescription': productDescription,
      'lotSerialNumber': lotSerialNumber,
      'purchaseOrderFileName': purchaseOrderFileName,
      'suppliersPackingListName': suppliersPackingListName,
      'inventoryOfDeliveredItemsName': inventoryOfDeliveredItemsName,
      'orderDate': orderDate.toIso8601String(),
      'drSIReferenceNum': drSIReferenceNum,
    };

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