class StockLocator {
  String itemCode = "";
  String brand = "";
  String productDescription = "";
  int lazcanoRef1 = 0;
  int lazcanoRef2 = 0;
  int gandiaColdStorage = 0;
  int gandiaRef1 = 0;
  int gandiaRef2 = 0;
  int limbaga = 0;
  int cebu = 0;

  StockLocator({
    required this.itemCode,
    required this.brand,
    required this.productDescription,
    required this.lazcanoRef1,
    required this.lazcanoRef2,
    required this.gandiaColdStorage,
    required this.gandiaRef1,
    required this.gandiaRef2,
    required this.limbaga,
    required this.cebu,
  });

  StockLocator.fromJson(Map<String, dynamic> json) {
    itemCode = json["itemCode"];
    brand = json["brand"];
    productDescription = json["productDescription"];
    lazcanoRef1 = json["lazcanoRef1"];
    lazcanoRef2 = json["lazcanoRef2"];
    gandiaColdStorage = json["gandiaColdStorage"];
    gandiaRef1 = json["gandiaRef1"];
    gandiaRef2 = json["gandiaRef2"];
    limbaga = json["limbaga"];
    cebu = json["cebu"];
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'brand': brand,
      'productDescription': productDescription,
      'lazcanoRef1': lazcanoRef1,
      'lazcanoRef2': lazcanoRef2,
      'gandiaColdStorage': gandiaColdStorage,
      'gandiaRef1': gandiaRef1,
      'gandiaRef2': gandiaRef2,
      'limbaga': limbaga,
      'cebu': cebu,
    };
  }
}
