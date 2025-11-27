class ItemLoc {
  int? itemLocId;
  int locationId;
  String? locationName;
  int quantity;

  ItemLoc({
    this.itemLocId,
    required this.locationId,
    this.locationName,
    required this.quantity,
  });

  factory ItemLoc.fromJson(Map<String, dynamic> json) {
    return ItemLoc(
      itemLocId: json['itemLocId'],
      locationId: json['locationId'],
      locationName: json['locationName'],
      quantity: json['quantity'],
    );
  }
}