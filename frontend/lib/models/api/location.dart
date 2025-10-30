class Location {
  int? locationId;
  String locationName;

  Location({
    this.locationId, 
    required this.locationName
  });

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
      locationId: json['locationId'],
      locationName: json['locationName']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "locationId": locationId,
      "locationName": locationName
    };
  }
}