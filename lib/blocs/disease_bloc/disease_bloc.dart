import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/disease.dart';
import '../../repositories/disease_repository.dart';

part 'disease_event.dart';
part 'disease_state.dart';

// Bloc
class DiseaseBloc extends Bloc<DiseaseEvent, DiseaseState> {
  final DiseaseRepository diseaseRepository;

  DiseaseBloc(this.diseaseRepository) : super(DiseasesLoadingState());

  @override
  Stream<DiseaseState> mapEventToState(DiseaseEvent event) async* {
    if (event is LoadDiseasesEvent) {
      yield DiseasesLoadingState();
      try {
        final diseases = await diseaseRepository.getDiseases();
        yield DiseasesLoadedState(diseases);
      } catch (_) {
        yield DiseasesErrorState();
      }
    }
  }
}
