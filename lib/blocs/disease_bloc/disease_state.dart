part of 'disease_bloc.dart';

/// The base class for all disease events.
abstract class DiseaseState {}

/// Represents the state when the disease bloc is in the initial state.
class DiseasesLoadingState extends DiseaseState {}

/// Represents the state when the disease bloc has successfully loaded the diseases.
class DiseasesLoadedState extends DiseaseState {
  final List<Disease> diseases;

  DiseasesLoadedState(this.diseases);
}

/// Represents the state when the disease bloc has encountered an error.
class DiseasesErrorState extends DiseaseState {}