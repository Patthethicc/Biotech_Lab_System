class Inventory {
  int? inventoryID = 0;
  String itemCode = "";
  String brand = "";
  int quantityOnHand = 0;
  String addedBy = "";
  String dateTimeAdded = "";

  Inventory({
    required this.inventoryID,
    required this.itemCode,
    required this.brand,
    required this.quantityOnHand,
    required this.addedBy,
    required this.dateTimeAdded
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json["inventoryId"];
    itemCode = json["itemCode"];
    brand = json["brand"];
    quantityOnHand = json["quantityOnHand"];
    addedBy = json["addedBy"];
    dateTimeAdded = json["dateTimeAdded"];
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryID,
      'itemCode': itemCode,
      'brand' : brand,
      'quantityOnHand': quantityOnHand,
      'addedBy': addedBy,
      'dateTimeAdded': dateTimeAdded
    };
  }
}