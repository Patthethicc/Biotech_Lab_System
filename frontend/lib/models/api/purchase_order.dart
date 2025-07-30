import 'dart:convert';

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => 'DataParsingException: $message';
}

class PurchaseOrder {
  final String purchaseOrderCode;
  final String? itemCode;
  final String? purchaseOrderFile;
  final String? suppliersPackingList;
  final int quantityPurchased;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final double cost;
  final String? addedBy;
  final DateTime? dateTimeAdded;
  final bool hasPurchaseOrderFile;
  final bool hasSuppliersPackingList;

  PurchaseOrder({
    required this.purchaseOrderCode,
    this.itemCode,
    this.purchaseOrderFile,
    this.suppliersPackingList,
    required this.quantityPurchased,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.cost,
    this.addedBy,
    this.dateTimeAdded,
    this.hasPurchaseOrderFile = false,
    this.hasSuppliersPackingList = false,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    if (json['purchaseOrderCode'] == null) {
      throw DataParsingException('Purchase order code is null from API response');
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

  Map<String, dynamic> toJson() {
    return {
      'purchaseOrderCode': purchaseOrderCode,
      'itemCode': itemCode,
      'purchaseOrderFile': purchaseOrderFile,
      'suppliersPackingList': suppliersPackingList,
      'quantityPurchased': quantityPurchased,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'cost': cost,
      'addedBy': addedBy,
      'dateTimeAdded': dateTimeAdded?.toIso8601String(),
    };
  }
}