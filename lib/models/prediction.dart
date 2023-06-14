
import 'disease.dart';

class Prediction {
  late Disease disease;
  late double probability;

  Prediction({required this.disease, required this.probability});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      disease: Disease.fromJson(json['disease']),
      probability: json['probability'],
    );
  }

  Map<String, dynamic> toJson() => {
    'disease': disease,
    'probability': probability,
  };
}