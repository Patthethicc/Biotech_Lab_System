class Inventory {
  int? inventoryID = 0;
  String itemCode = "";
  String brand = "";
  String productDescription = "";
  String lotSerialNumber = "";
  double cost = 0;
  String expiryDate = "";
  int stocksManila = 0;
  int stocksCebu = 0;
  int quantityOnHand = 0;
  String addedBy = "";
  String dateTimeAdded = "";

  Inventory({
    required this.inventoryID,
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.lotSerialNumber,
    required this.cost,
    required this.expiryDate,
    required this.stocksManila,
    required this.stocksCebu,
    required this.addedBy,
    required this.dateTimeAdded
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json["inventoryId"];
    itemCode = json["itemCode"];
    brand = json["brand"];
    productDescription = json["productDescription"];
    lotSerialNumber = json["lotSerialNumber"];
    cost = json["cost"];
    expiryDate = json["expiryDate"];
    stocksManila = json["stocksManila"];
    stocksCebu = json["stocksCebu"];
    quantityOnHand = json["quantityOnHand"];
    addedBy = json["addedBy"];
    dateTimeAdded = json["dateTimeAdded"];
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryID,
      'itemCode': itemCode,
      'brand' : brand,
      'productDescription' : productDescription,
      'lotSerialNumber' : lotSerialNumber,
      'cost': cost,
      'expiryDate': expiryDate,
      'stocksManila': stocksManila,
      'stocksCebu': stocksCebu,
      'addedBy': addedBy,
      'dateTimeAdded': dateTimeAdded
    };
  }
}