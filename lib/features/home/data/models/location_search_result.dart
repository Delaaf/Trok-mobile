class LocationSearchResult {
  const LocationSearchResult({required this.id, required this.name, required this.latitude, required this.longitude});

  final int id;
  final String name;
  final double latitude;
  final double longitude;

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class NearestLocationResult {
  const NearestLocationResult({required this.name, required this.latitude, required this.longitude, required this.distanceKm});

  final String name;
  final double latitude;
  final double longitude;
  final double distanceKm;

  factory NearestLocationResult.fromJson(Map<String, dynamic> json) {
    return NearestLocationResult(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }
}
