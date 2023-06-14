part of 'diagnosis_bloc.dart';

@immutable
abstract class DiagnosisEvent {}

class FetchDiagnoses extends DiagnosisEvent {}

class Diagnose extends DiagnosisEvent {
  final FormData data;

  Diagnose(this.data);
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
