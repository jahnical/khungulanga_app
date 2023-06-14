import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_navigation_event.dart';
part 'home_navigation_state.dart';

class HomeNavigationBloc extends Bloc<HomeNavigationEvent, HomeNavigationState> {
  HomeNavigationBloc() : super(HomeNavigationHistory()) {
    on<HomeNavigationEvent>((event, emit) {
      if (event is NavigateToHistory) {
        emit(HomeNavigationHistory());
      } else if (event is NavigateToScan) {
        emit(HomeNavigationScan());
      } else if (event is NavigateToDermatologists) {
        emit(HomeNavigationDermatologists());
      } else if (event is NavigateToAppointments) {
        emit(HomeNavigationAppointments());
      } else if (event is NavigateToSlots) {
        emit(HomeNavigationSlots());
      }
    });
  }
}
