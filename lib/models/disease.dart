
import 'treatment.dart';

/// Model for disease
class Disease {
  final String name;
  final String description;
  final String severity;
  final List<Treatment> treatments;
  final int id;

  /// Constructs a new instance of the Disease class.
  /// [name] is the name of the disease.
  /// [description] is the description of the disease.
  /// [severity] is the severity of the disease.
  /// [treatments] is the list of treatments for the disease.
  /// [id] is the ID of the disease.
  /// Returns a Disease object.
  Disease({required this.id, required this.name, required this.description, required this.severity, required this.treatments});

  /// Constructs a Disease object from a JSON map.
  /// [json] is the JSON map representing the Disease.
  /// Returns a Disease object.
  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      severity: json['severity'],
      treatments: json['treatments'].map((e) => Treatment.fromJson(e)).toList().cast<Treatment>(),
    );
  }

  /// Converts the Disease object to a JSON map.
  /// Returns a JSON map representing the Disease.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'severity': severity,
      'treatments': treatments.map((e) => e.toJson()).toList(),
    };
  }
}