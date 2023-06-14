part of 'dermatologists_bloc.dart';

@immutable
abstract class DermatologistsState extends Equatable {
  const DermatologistsState();

  @override
  List<Object> get props => [];
}

class DermatologistsLoadingState extends DermatologistsState {}

class DermatologistsLoadedState extends DermatologistsState {
  final List<Dermatologist> dermatologists;

  const DermatologistsLoadedState({required this.dermatologists});

  @override
  List<Object> get props => [dermatologists];
}

class DermatologistsErrorState extends DermatologistsState {
  final String errorMessage;

  const DermatologistsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}