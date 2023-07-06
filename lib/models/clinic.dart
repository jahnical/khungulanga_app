
/// A class that represents a clinic.
class Clinic {
  final String name;
  final double latitude;
  final double longitude;
  final int? id;

  /// Constructs a new instance of the Clinic class.
  /// [name] is the name of the clinic.
  /// [latitude] is the latitude of the clinic.
  /// [longitude] is the longitude of the clinic.
  /// [id] is the ID of the clinic.
  Clinic({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.id,
  });

  /// Constructs a Clinic object from a JSON map.
  /// [json] is the JSON map representing the Clinic.
  /// Returns a Clinic object.
  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      id: json['id'],
    );
  }

  /// Converts the Clinic object to a JSON map.
  /// Returns a JSON map representing the Clinic.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'id': id,
    };
  }
}
