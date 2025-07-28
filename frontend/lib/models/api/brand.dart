class Brand {
  final int brandId;
  final String brandName;

  Brand({
    required this.brandId,
    required this.brandName});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['user_id'],
      brandName: json['firstName']
    );
  }

   Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'brandName': brandName
  };
}