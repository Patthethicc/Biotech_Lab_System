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
      name: json['name'],
      address: json['address'],
      salesRepresentative: json['salesRepresentative'],
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
}
