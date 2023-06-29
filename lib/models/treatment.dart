
class Treatment {
  final String title;
  final String description;
  final int? id;

  Treatment({required this.title, required this.description, this.id});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      title: json['title'],
      description: json['description'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'id': id,
    };
  }
}