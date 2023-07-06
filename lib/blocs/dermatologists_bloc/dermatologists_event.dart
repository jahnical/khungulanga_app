part of 'dermatologists_bloc.dart';

/// The base class for all dermatologists events.
abstract class DermatologistsEvent extends Equatable {
  const DermatologistsEvent();

  @override
  List<Object> get props => [];
}

/// Represents the event when the dermatologists bloc is initialized.
class LoadDermatologistsEvent extends DermatologistsEvent {}