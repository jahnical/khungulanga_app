part of 'home_navigation_bloc.dart';

@immutable
abstract class HomeNavigationEvent {}

class NavigateToHistory extends HomeNavigationEvent {}

class NavigateToScan extends HomeNavigationEvent {}

class NavigateToDermatologists extends HomeNavigationEvent {}

class NavigateToSlots extends HomeNavigationEvent {}

class NavigateToAppointments extends HomeNavigationEvent {}