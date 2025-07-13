class TransactionEntry {
  final String reference;
  final DateTime transactionDate;
  final String brand;
  final String itemDescription;
  final int lotNumber;
  final DateTime expiryDate;
  final int quantity;
  final String stockLocation;

  TransactionEntry({
    required this.reference,
    required this.transactionDate,
    required this.brand,
    required this.itemDescription,
    required this.lotNumber,
    required this.expiryDate,
    required this.quantity,
    required this.stockLocation,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      reference: json['reference'],
      transactionDate: json['transactionDate'],
      brand: json['brand'],
      itemDescription: json['itemDescription'],
      lotNumber: json['lotNumber'],
      expiryDate: json['expiryDate'],
      quantity: json['quantity'],
      stockLocation: json['stockLocation']
    );
  }

  Map<String, dynamic> toJson() => {
    'reference' : reference,
    'transactionDate' : transactionDate,
    'brand' : brand,
    'itemDescription' : itemDescription,
    'lotNumber' : lotNumber,
    'expiryDate' : expiryDate,
    'quantity' : quantity,
    'stockLocation' : stockLocation
  };
}