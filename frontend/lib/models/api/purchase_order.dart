class PurchaseOrder {
  String itemCode;
  String brand;
  String productDescription;
  num packSize;
  num quantity;
  num unitCost;
  num totalCost;
  String poPIreference;

  PurchaseOrder({
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.packSize,
    required this.quantity,
    required this.unitCost,
    required this.poPIreference,
  }) : totalCost = quantity * unitCost; // compute automatically

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] ?? 0;
    final cost = json['unitCost'] ?? 0;
    return PurchaseOrder(
      itemCode: json['itemCode'] ?? 'Unknown Code',
      brand: json['brand'] ?? 'No Brand',
      productDescription: json['productDescription'] ?? 'No Description',
      packSize: json['packSize'] ?? 0,
      quantity: qty,
      unitCost: cost,
      poPIreference: json['poPIreference'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'brand': brand,
      'productDescription': productDescription,
      'packSize': packSize,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'poPIreference': poPIreference,
    };
  }
}
