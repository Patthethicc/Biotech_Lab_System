class Customer {
  final String customerId;
  final String name;
  final String address;
  final String salesRepresentative;

  Customer({
    required this.customerId,
    required this.name,
    required this.address,
    required this.salesRepresentative,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'].toString(), 
      name: json['name'] as String,
      address: json['address'] as String,
      salesRepresentative: json['salesRepresentative'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'address': address,
      'salesRepresentative': salesRepresentative,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          customerId == other.customerId;

  @override
  int get hashCode => customerId.hashCode;
}
