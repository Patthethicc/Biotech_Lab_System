class PurchaseOrder {
  String? itemCode;
  int brandId;
  String? brandName;
  String productDescription;
  num packSize;
  num quantity;
  num unitCost;
  num totalCost;
  String poPireference;
  int addedBy;
  DateTime? dateTimeAdded;

  PurchaseOrder({
    this.itemCode,
    required this.brandId,
    this.brandName,
    required this.productDescription,
    required this.packSize,
    required this.quantity,
    required this.unitCost,
    required this.poPireference,
    required this.addedBy,
    this.dateTimeAdded,
  }) : totalCost = quantity * unitCost;

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] ?? 0;
    final cost = json['unitCost'] ?? 0;
    return PurchaseOrder(
      itemCode: json['itemCode'],
      brandId: json['brandId'],
      brandName: json['brandName'],
      productDescription: json['productDescription'] ?? 'No Description',
      packSize: json['packSize'] ?? 0,
      quantity: qty,
      unitCost: cost,
      poPireference: json['poPireference'] ?? 'N/A',
      addedBy: json['addedBy'],
      dateTimeAdded: json['dateTimeAdded'] != null
        ? DateTime.parse(json['dateTimeAdded'])
        : null,
    );
  }

  Map<String, dynamic> toJson({bool includeDate = false}) {
    final data = {
      'itemCode': itemCode,
      'brandId': brandId,
      'packSize': packSize,
      'quantity': quantity,
      'unitCost': unitCost,
      'poPireference': poPireference,
      'addedBy': addedBy,
      'productDescription': productDescription
    };
    if (includeDate && dateTimeAdded != null) {
      data['dateTimeAdded'] = dateTimeAdded!.toIso8601String();
    }
    return data;
  }
}
