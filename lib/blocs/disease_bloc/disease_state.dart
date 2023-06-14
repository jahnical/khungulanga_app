part of 'disease_bloc.dart';

abstract class DiseaseState {}

class DiseasesLoadingState extends DiseaseState {}

class DiseasesLoadedState extends DiseaseState {
  final List<Disease> diseases;

  DiseasesLoadedState(this.diseases);
}

class DiseasesErrorState extends DiseaseState {}