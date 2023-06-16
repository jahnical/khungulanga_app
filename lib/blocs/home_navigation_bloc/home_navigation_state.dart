part of 'home_navigation_bloc.dart';

@immutable
abstract class HomeNavigationState {}

class HomeNavigationHistory extends HomeNavigationState {}

class HomeNavigationScan extends HomeNavigationState {}

class HomeNavigationDermatologists extends HomeNavigationState {}

class HomeNavigationAppointments extends HomeNavigationState {}

class HomeNavigationSlots extends HomeNavigationState {}

class HomeNavigationResults extends HomeNavigationState {}