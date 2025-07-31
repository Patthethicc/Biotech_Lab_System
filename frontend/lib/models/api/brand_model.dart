class BrandModel {
  final int? brandId;
  final String brandName;
  final String? abbreviation;
  final int? latestSequence;

  BrandModel({
    this.brandId,
    required this.brandName,
    this.abbreviation ,
    this.latestSequence });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
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