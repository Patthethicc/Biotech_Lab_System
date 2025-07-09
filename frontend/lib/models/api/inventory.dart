class Inventory {
  final int inventoryID;
  final String itemCode;
  final int quantityOnHand;

  const Inventory({
    required this.inventoryID,
    required this.itemCode,
    required this.quantityOnHand
  });

  static Inventory fromJson(json) => Inventory(
    inventoryID: json["inventoryId"],
    itemCode: json["itemCode"],
    quantityOnHand: json["quantityOnHand"]
  );

}