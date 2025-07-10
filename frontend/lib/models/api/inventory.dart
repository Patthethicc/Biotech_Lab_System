class Inventory {
  int? inventoryID = 0;
  String itemCode = "";
  int quantityOnHand = 0;
  String lastUpdated = "";

  Inventory({
    required this.inventoryID,
    required this.itemCode,
    required this.quantityOnHand,
    required this.lastUpdated
  });

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json["inventoryId"];
    itemCode = json["itemCode"];
    quantityOnHand = json["quantityOnHand"];
    lastUpdated = json["lastUpdated"];
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryID,
      'itemCode': itemCode,
      'quantityOnHand': quantityOnHand,
      'lastUpdated': lastUpdated
    };
  }
}