
class TransactionEntry {
  final String reference;
  final DateTime transactionDate;
  final String brand;
  final String itemDescription;
  final String lotNumber;
  final DateTime expiryDate;
  final double cost; 
  final int quantity;
  final String stockLocation;

  TransactionEntry({
    required this.reference,
    required this.transactionDate,
    required this.brand,
    required this.itemDescription,
    required this.lotNumber,
    required this.expiryDate,
    required this.cost,
    required this.quantity,
    required this.stockLocation,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      reference: json['drSIReferenceNum'],
      transactionDate: DateTime.parse(json['transactionDate']),
      brand: json['brand'],
      itemDescription: json['productDescription'],
      lotNumber: json['lotSerialNumber'].toString(),
      expiryDate: DateTime.parse(json['expiryDate']),
      cost: json['cost'],
      quantity: json['quantity'],
      stockLocation: json['stockLocation']
    );
  }

  Map<String, dynamic> toJson() => {
    'drSIReferenceNum' : reference,
    'transactionDate' : transactionDate.toIso8601String(),
    'brand' : brand,
    'productDescription' : itemDescription,
    'lotSerialNumber' : lotNumber,
    'expiryDate' : expiryDate.toIso8601String(),
    'cost' : cost,
    'quantity' : quantity,
    'stockLocation' : stockLocation
  };
}