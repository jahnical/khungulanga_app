part of 'diagnosis_bloc.dart';


@immutable
abstract class DiagnosisState {
  final List<Diagnosis> diagnoses;

  DiagnosisState(this.diagnoses);
}

class DiagnosisInitial extends DiagnosisState {
  DiagnosisInitial(super.diagnoses);
}

class DiagnosisLoading extends DiagnosisState {
  DiagnosisLoading(super.diagnoses);
}

class DiagnosisLoaded extends DiagnosisState {
  DiagnosisLoaded(super.diagnoses);
}

class DiagnosisError extends DiagnosisState {
  final String message;
  DiagnosisError(super.diagnoses, {required this.message});
}

class DiagnosisDeleting extends DiagnosisState {
  Diagnosis diagnosis;

  DiagnosisDeleting(super.diagnoses, this.diagnosis);
}

class DiagnosisDeleted extends DiagnosisState {
  DiagnosisDeleted(super.diagnoses);
}

class DiagnosisDeletingError extends DiagnosisState {
  final String message;
  DiagnosisDeletingError(super.diagnoses, {required this.message});
}


class ConfirmingDiagnosisDelete extends DiagnosisState {
  Diagnosis diagnosis;

  ConfirmingDiagnosisDelete(super.diagnoses, this.diagnosis);
}

class Diagnosing extends DiagnosisState {
  Diagnosing(super.diagnoses);
}

class DiagnosisSuccess extends DiagnosisState {
  Diagnosis diagnosis;

  DiagnosisSuccess(super.diagnoses, this.diagnosis);
}

class DiagnosingError206 extends DiagnosisState {
  String message;

  DiagnosingError206(super.diagnoses, this.message);

}

class DiagnosingErrorAny extends DiagnosisState {
  String message;

  DiagnosingErrorAny(super.diagnoses, this.message);

}