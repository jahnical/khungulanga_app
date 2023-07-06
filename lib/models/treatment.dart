/// Model for treatment
class Treatment {
  final String title;
  final String description;
  final int? id;

  /// Constructs a new instance of the Treatment class.
  /// [title] is the title of the treatment.
  /// [description] is the description of the treatment.
  Treatment({required this.title, required this.description, this.id});

  /// Constructs a Treatment object from a JSON map.
  /// [json] is the JSON map representing the Treatment.
  /// Returns a Treatment object.
  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      title: json['title'],
      description: json['description'],
      id: json['id'],
    );
  }

  /// Converts the Treatment object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'id': id,
    };
  }
}