class Brand {
  final int brandId;
  final String brandName;
  final String abbreviation;
  final int latestSequence;

  Brand({
    required this.brandId,
    required this.brandName,
    required this.abbreviation,
    required this.latestSequence});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['brandId'],
      brandName: json['brandName'],
      abbreviation: json['abbreviation'],
      latestSequence: json['latestSequence']
    );
  }

   Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'brandName': brandName,
    'abbreviation': abbreviation,
    'latestSequence': latestSequence
  };
}