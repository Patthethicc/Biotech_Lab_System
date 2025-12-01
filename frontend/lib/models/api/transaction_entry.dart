
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
      reference: json['drSIReferenceNum'] ?? 'N/A',
      transactionDate: json['transactionDate'] != null ? DateTime.parse(json['transactionDate']) : DateTime.now(),
      brand: json['brand'] ?? 'N/A',
      itemDescription: json['productDescription'] ?? 'N/A',
      lotNumber: json['lotSerialNumber']?.toString() ?? 'N/A',
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : DateTime.now(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      stockLocation: json['stockLocation'] ?? 'N/A'
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