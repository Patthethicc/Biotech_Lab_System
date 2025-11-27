class Inventory {
  String poPireference;
  String invoiceNum;
  String itemCode;
  String itemDescription;
  int brandId;
  int packSize;
  int lotNum;
  String expiry;
  double costOfSale;
  String? note;
  int addedBy;
  String dateTimeAdded;
  int quantity;

  Inventory({
    required this.poPireference,
    required this.invoiceNum,
    required this.itemCode,
    required this.itemDescription,
    required this.brandId,
    required this.packSize,
    required this.lotNum,
    required this.expiry,
    required this.costOfSale,
    this.note,
    required this.addedBy,
    required this.dateTimeAdded,
    required this.quantity
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      poPireference: json["poPireference"],
      invoiceNum: json["invoiceNum"],
      itemCode: json["itemCode"],
      itemDescription: json["itemDescription"],
      brandId: json["brandId"],
      packSize: json["packSize"],
      lotNum: json["lotNum"],
      expiry: json["expiry"],
      costOfSale: (json["costOfSale"] is int)
        ? (json["costOfSale"] as int).toDouble()
        : json["costOfSale"],
      note: json["note"],
      addedBy: json["addedBy"],
      dateTimeAdded: json["dateTimeAdded"],
      quantity: json["quantity"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "poPireference": poPireference,
      "invoiceNum": invoiceNum,
      "itemCode": itemCode,
      "itemDescription": itemDescription,
      "brandId": brandId,
      "packSize": packSize,
      "lotNum": lotNum,
      "expiry": expiry,
      "quantity": quantity,
      "costOfSale": costOfSale,
      "note": note,
      "addedBy": addedBy,
      "dateTimeAdded": dateTimeAdded,
    };
  }
}