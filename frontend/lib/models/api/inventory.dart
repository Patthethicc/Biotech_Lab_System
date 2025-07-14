class Inventory {
  int? inventoryID = 0;
  String itemCode = "";
  String brand = "";
  String item ="";
  int quantityOnHand = 0;
  String lastUpdated = "";

  Inventory({
    required this.inventoryID,
    required this.itemCode,
    required this.brand,
    required this.item,
    required this.quantityOnHand,
    required this.lastUpdated
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json["inventoryId"];
    itemCode = json["itemCode"];
    brand = json["brand"];
    item = json["item"];
    quantityOnHand = json["quantityOnHand"];
    lastUpdated = json["lastUpdated"];
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryID,
      'itemCode': itemCode,
      'brand' : brand,
      'item' : item,
      'quantityOnHand': quantityOnHand,
      'lastUpdated': lastUpdated
    };
  }
}