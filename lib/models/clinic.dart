class Clinic {
  final String name;
  final double latitude;
  final double longitude;
  final int? id;

  Clinic({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.id,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'id': id,
    };
  }
}
