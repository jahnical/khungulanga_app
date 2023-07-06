part of 'home_navigation_bloc.dart';

@immutable
abstract class HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the history screen.
class HomeNavigationHistory extends HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the scan screen.
class HomeNavigationScan extends HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the dermatologists screen.
class HomeNavigationDermatologists extends HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the appointments screen.
class HomeNavigationAppointments extends HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the slots screen.
class HomeNavigationSlots extends HomeNavigationState {}

/// Represents the state indicating that the home navigation is in the results screen.
class HomeNavigationResults extends HomeNavigationState {}
