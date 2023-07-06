part of 'diagnosis_bloc.dart';



@immutable
/// The base class for all diagnosis states.
abstract class DiagnosisState {
  final List<Diagnosis> diagnoses;

  DiagnosisState(this.diagnoses);
}

/// Represents the initial state of the diagnosis feature.
class DiagnosisInitial extends DiagnosisState {
  DiagnosisInitial(super.diagnoses);
}

/// Represents the state when the diagnosis information has been updated.
class DiagnosisUpdated extends DiagnosisState {
  DiagnosisUpdated(super.diagnoses);
}

/// Represents the state when the diagnosis data is being loaded.
class DiagnosisLoading extends DiagnosisState {
  DiagnosisLoading(super.diagnoses);
}

/// Represents the state when the diagnosis data has been successfully loaded.
class DiagnosisLoaded extends DiagnosisState {
  DiagnosisLoaded(super.diagnoses);
}

/// Represents the state when an error occurs during the diagnosis process.
class DiagnosisError extends DiagnosisState {
  final String message;

  DiagnosisError(super.diagnoses, {required this.message});
}

/// Represents the state when a diagnosis is being deleted.
class DiagnosisDeleting extends DiagnosisState {
  Diagnosis diagnosis;

  DiagnosisDeleting(super.diagnoses, this.diagnosis);
}

/// Represents the state when a diagnosis has been successfully deleted.
class DiagnosisDeleted extends DiagnosisState {
  DiagnosisDeleted(super.diagnoses);
}

/// Represents the state when an error occurs during the diagnosis deletion process.
class DiagnosisDeletingError extends DiagnosisState {
  final String message;

  DiagnosisDeletingError(super.diagnoses, {required this.message});
}

/// Represents the state when a confirmation for diagnosis deletion is being obtained.
class ConfirmingDiagnosisDelete extends DiagnosisState {
  Diagnosis diagnosis;

  ConfirmingDiagnosisDelete(super.diagnoses, this.diagnosis);
}

/// Represents the state when a diagnosis is being processed.
class Diagnosing extends DiagnosisState {
  Diagnosing(super.diagnoses);
}

/// Represents the state when a diagnosis is successfully made.
class DiagnosisSuccess extends DiagnosisState {
  Diagnosis diagnosis;

  DiagnosisSuccess(super.diagnoses, this.diagnosis);
}

/// Represents the state when an error occurs during the diagnosis process with an HTTP 206 status code.
class DiagnosingError206 extends DiagnosisState {
  String message;

  DiagnosingError206(super.diagnoses, this.message);
}

/// Represents the state when an error occurs during the diagnosis process with any other error.
class DiagnosingErrorAny extends DiagnosisState {
  String message;

  DiagnosingErrorAny(super.diagnoses, this.message);
}