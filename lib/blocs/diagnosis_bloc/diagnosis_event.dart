part of 'diagnosis_bloc.dart';

@immutable
/// The base class for all diagnosis events.
abstract class DiagnosisEvent {}

/// Represents the event to fetch diagnoses.
class FetchDiagnoses extends DiagnosisEvent {}

/// Represents the event to perform a diagnosis.
class Diagnose extends DiagnosisEvent {
  final FormData data;
  final CancelToken cancelToken;

  Diagnose(this.data, {required this.cancelToken});
}

/// Represents the event to delete a diagnosis.
class DeleteDiagnosis extends DiagnosisEvent {
  final Diagnosis diagnosis;

  DeleteDiagnosis(this.diagnosis);
}

/// Represents the event when the delete diagnosis button is pressed.
class DeleteDiagnosisPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;

  DeleteDiagnosisPressed(this.diagnosis);
}

/// Represents the event to update a diagnosis.
class UpdateDiagnosis extends DiagnosisEvent {
  final Diagnosis diagnosis;

  UpdateDiagnosis(this.diagnosis);
}

/// Represents the event when the submit treatment button is pressed.
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

/// Represents the event when the refer treatment button is pressed.
class ReferTreatmentPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;
  final Prediction prediction;

  ReferTreatmentPressed({
    required this.diagnosis,
    required this.prediction
  });
}

/// Represents the event when the reject diagnosis button is pressed.
class RejectDiagnosisPressed extends DiagnosisEvent {
  final Diagnosis diagnosis;

  RejectDiagnosisPressed(this.diagnosis);
}
