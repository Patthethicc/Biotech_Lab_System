import 'dart:convert'; 

class Item {
  final String itemCode; 
  String brand;
  String productDescription;
  String lotSerialNumber;
  DateTime? expiryDate; 
  String stocksManila; 
  String stocksCebu;   
  String purchaseOrderReferenceNumber;
  String supplierPackingList;
  String drsiReferenceNumber;

  Item({
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.lotSerialNumber,
    this.expiryDate, 
    required this.stocksManila,
    required this.stocksCebu,
    required this.purchaseOrderReferenceNumber,
    required this.supplierPackingList,
    required this.drsiReferenceNumber,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['itemCode'] as String, // Ensure string type
      brand: json['brand'] as String,
      productDescription: json['productDescription'] as String,
      lotSerialNumber: json['lotSerialNumber'] as String,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      stocksManila: json['stocksManila'] as String,
      stocksCebu: json['stocksCebu'] as String,
      purchaseOrderReferenceNumber:
          json['purchaseOrderReferenceNumber'] as String,
      supplierPackingList: json['supplierPackingList'] as String,
      drsiReferenceNumber: json['drsiReferenceNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'brand': brand,
      'productDescription': productDescription,
      'lotSerialNumber': lotSerialNumber,
      'expiryDate': expiryDate?.toIso8601String(), 
      'stocksManila': stocksManila,
      'stocksCebu': stocksCebu,
      'purchaseOrderReferenceNumber': purchaseOrderReferenceNumber,
      'supplierPackingList': supplierPackingList,
      'drsiReferenceNumber': drsiReferenceNumber,
    };
  }

  @override
  String toString() {
    return 'Item{itemCode: $itemCode, brand: $brand, productDescription: $productDescription, '
           'stocksManila: $stocksManila, stocksCebu: $stocksCebu}';
  }
}