class Inventory {
  int inventoryID = 0;
  String itemCode = "";
  int quantityOnHand = 0;

  Inventory(
    this.inventoryID,
    this.itemCode,
    this.quantityOnHand
  );

  Inventory.fromJson(Map<String, dynamic> json) {
    inventoryID = json["inventoryId"];
    itemCode = json["itemCode"];
    quantityOnHand = json["quantityOnHand"];
  }

}