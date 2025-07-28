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

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => 'DataParsingException: $message';
}