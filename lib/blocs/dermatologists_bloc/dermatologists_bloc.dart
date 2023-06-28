import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/dermatologist.dart';
import '../../models/diagnosis.dart';
import '../../repositories/dermatologist_repository.dart';

part 'dermatologists_event.dart';
part 'dermatologists_state.dart';

// Define the BLoC class
class DermatologistsBloc extends Bloc<DermatologistsEvent, DermatologistsState> {
  final List<double> userLocation;

  DermatologistsBloc({required this.userLocation}) : super(DermatologistsLoadingState());

  @override
  Stream<DermatologistsState> mapEventToState(DermatologistsEvent event) async* {
    if (event is LoadDermatologistsEvent) {
      yield DermatologistsLoadingState();
      try {
        final dermatologists = await DermatologistRepository().getNearbyDermatologists(userLocation[0], userLocation[1]);
        dermatologists.sort((a, b) => a.user.firstName.compareTo(b.user.firstName));
        yield DermatologistsLoadedState(dermatologists: dermatologists);
      } catch (e) {
        yield DermatologistsErrorState(errorMessage: 'Failed to load dermatologists $e');
      }
    }
  }
}
