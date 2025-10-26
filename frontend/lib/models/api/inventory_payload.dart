import 'package:frontend/models/api/inventory.dart';
import 'package:frontend/models/api/item_loc.dart';

class InventoryPayload {
  Inventory inventory;
  List<ItemLoc> locations;

  InventoryPayload({
    required this.inventory, required this.locations
  });

  factory InventoryPayload.fromJson(Map<String, dynamic> json) {
    return InventoryPayload(
      inventory: Inventory.fromJson(json['inventory']),
      locations: (json['locations'] as List)
          .map((locJson) => ItemLoc.fromJson(locJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "inventory": inventory.toJson(),
      "locations": locations.map((loc) => {
        "locationId": loc.locationId,
        "quantity": loc.quantity,
      }).toList(),
    };
  }
}