
class Treatment {
  final String title;
  final String description;

  Treatment({required this.title, required this.description});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}