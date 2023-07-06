part of 'dermatologists_bloc.dart';

@immutable
/// Abstract class for all dermatologists states.
abstract class DermatologistsState extends Equatable {
  const DermatologistsState();

  @override
  List<Object> get props => [];
}

/// Represents the state when the dermatologists bloc is in the initial state.
class DermatologistsLoadingState extends DermatologistsState {}

/// Represents the state when the dermatologists bloc has successfully loaded the dermatologists.
class DermatologistsLoadedState extends DermatologistsState {
  final List<Dermatologist> dermatologists;

  const DermatologistsLoadedState({required this.dermatologists});

  @override
  List<Object> get props => [dermatologists];
}

/// Represents the state when the dermatologists bloc has encountered an error.
class DermatologistsErrorState extends DermatologistsState {
  final String errorMessage;

  const DermatologistsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}