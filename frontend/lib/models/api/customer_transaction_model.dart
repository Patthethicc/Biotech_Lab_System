class Sold {
  final String itemId;
  final String lotNumber;
  final int quantity;
  final double unitRetailPrice;
  final String brandName;
  final String itemDescription;
  final String? location;

  Sold({
    required this.itemId,
    required this.lotNumber,
    required this.quantity,
    required this.unitRetailPrice,
    required this.brandName,
    required this.itemDescription,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'lotNumber': lotNumber,
      'quantity': quantity,
      'unitRetailPrice': unitRetailPrice,
      'brandName': brandName,
      'itemDescription': itemDescription,
      'location': location,
    };
  }

  factory Sold.fromJson(Map<String, dynamic> json) {
    return Sold(
      itemId: json['itemId'].toString(),
      lotNumber: json['lotNumber'].toString(),
      quantity: json['quantity'],
      unitRetailPrice: (json['unitRetailPrice'] as num).toDouble(),
      brandName: json['brandName'] ?? 'N/A',
      itemDescription: json['itemDescription'] ?? 'N/A',
      location: json['location'],
    );
  }
}

class CustomerTransaction {
  final String invoiceReference;
  final DateTime transactionDate;
  final String customerId;
  final String customerName;
  final List<Sold> items;
  final String? transactionId;
  final double? totalRetailPrice;

  CustomerTransaction({
    required this.invoiceReference,
    required this.transactionDate,
    required this.customerId,
    required this.customerName,
    required this.items,
    this.transactionId,
    this.totalRetailPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoiceReference': invoiceReference,
      'transactionDate': transactionDate.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalRetailPrice': totalRetailPrice,
    };
  }

  factory CustomerTransaction.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<Sold> items = itemsList.map((i) => Sold.fromJson(i)).toList();

    return CustomerTransaction(
      transactionId: json['transactionId']?.toString(),
      invoiceReference: json['invoiceReference'],
      transactionDate: DateTime.parse(json['transactionDate']),
      customerId: json['customerId'].toString(),
      customerName: json['customerName'] ?? 'N/A',
      totalRetailPrice: (json['totalRetailPrice'] as num?)?.toDouble(),
      items: items,
    );
  }
}
