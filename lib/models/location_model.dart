// location_model.dart
class LocationModel {
  final int? id;
  final String cityName;
  final double latitude;
  final double longitude;

  LocationModel({
    this.id,
    required this.cityName,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      cityName: map['cityName'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
