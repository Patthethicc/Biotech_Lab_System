class LocationStock {
  int locationId;
  String locationName;
  int quantity;

  LocationStock({
    required this.locationId,
    required this.locationName,
    required this.quantity,
  });

  factory LocationStock.fromJson(Map<String, dynamic> json) {
    return LocationStock(
      locationId: json["locationId"],
      locationName: json["locationName"],
      quantity: json["quantity"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "locationId": locationId,
      "locationName": locationName,
      "quantity": quantity,
    };
  }
}