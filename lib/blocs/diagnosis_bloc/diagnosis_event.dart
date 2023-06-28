part of 'diagnosis_bloc.dart';

@immutable
abstract class DiagnosisEvent {}

class FetchDiagnoses extends DiagnosisEvent {}

class Diagnose extends DiagnosisEvent {
  final FormData data;
  final CancelToken cancelToken;

  Diagnose(this.data, {required this.cancelToken});
}

class DeleteDiagnosis extends DiagnosisEvent {
  final Diagnosis diagnosis;

  DeleteDiagnosis(this.diagnosis);
}

class DeleteDiagnosisPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;

  DeleteDiagnosisPressed(this.diagnosis);
}

class UpdateDiagnosis extends DiagnosisEvent {
  final Diagnosis diagnosis;

  UpdateDiagnosis(this.diagnosis);
}

class SubmitTreatmentPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;
  final Prediction? prediction;
  final String treatment;

  SubmitTreatmentPressed({
    required this.diagnosis,
    required this.prediction,
    required this.treatment
  });
}

class ReferTreatmentPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;
  final Prediction prediction;

  ReferTreatmentPressed({
    required this.diagnosis,
    required this.prediction
});
}

class RejectDiagnosisPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;

  RejectDiagnosisPressed(this.diagnosis);
}
