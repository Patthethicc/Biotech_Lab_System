import 'package:frontend/models/api/location_stock.dart';

class Inventory {
  String poPIreference;
  String invoiceNum;
  String itemCode;
  String itemDescription;
  String brand;
  num packSize;
  int lotNumber;
  String expiryDate;
  double costOfSale;
  List<LocationStock> locations;
  String? note;
  String addedBy;
  String dateTimeAdded;
  int get quantity => locations.fold(0, (sum, loc) => sum + loc.quantity);

  Inventory({
    required this.poPIreference,
    required this.invoiceNum,
    required this.itemCode,
    required this.itemDescription,
    required this.brand,
    required this.packSize,
    required this.lotNumber,
    required this.expiryDate,
    required this.costOfSale,
    required this.locations,
    this.note,
    required this.addedBy,
    required this.dateTimeAdded,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      poPIreference: json["poPIreference"],
      invoiceNum: json["invoiceNum"],
      itemCode: json["itemCode"],
      itemDescription: json["itemDescription"],
      brand: json["brand"],
      packSize: json["packSize"],
      lotNumber: json["lotNumber"],
      expiryDate: json["expiryDate"],
      costOfSale: (json["costOfSale"] is int)
        ? (json["costOfSale"] as int).toDouble()
        : json["costOfSale"],
      locations: (json["location"] as List<dynamic>?)
        ?.map((e) => LocationStock.fromJson(e))
        .toList() ?? [],
      note: json["note"],
      addedBy: json["addedBy"],
      dateTimeAdded: json["dateTimeAdded"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "poPIreference": poPIreference,
      "invoiceNum": invoiceNum,
      "itemCode": itemCode,
      "itemDescription": itemDescription,
      "brand": brand,
      "packSize": packSize,
      "lotNumber": lotNumber,
      "expiryDate": expiryDate,
      "quantity": quantity,
      "costOfSale": costOfSale,
      "locations": locations.map((e) => e.toJson()).toList(),
      "note": note,
      "addedBy": addedBy,
      "dateTimeAdded": dateTimeAdded,
    };
  }
}