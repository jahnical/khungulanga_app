part of 'disease_bloc.dart';

/// The base class for all disease events.
abstract class DiseaseEvent {}

/// Represents the event when the disease bloc is initialized.
class LoadDiseasesEvent extends DiseaseEvent {}
