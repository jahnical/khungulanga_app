part of 'dermatologists_bloc.dart';

abstract class DermatologistsEvent extends Equatable {
  const DermatologistsEvent();

  @override
  List<Object> get props => [];
}

class LoadDermatologistsEvent extends DermatologistsEvent {}