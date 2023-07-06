part of 'home_navigation_bloc.dart';

@immutable
abstract class HomeNavigationEvent {}

/// Event to navigate to the history screen in the home navigation.
class NavigateToHistory extends HomeNavigationEvent {}

/// Event to navigate to the scan screen in the home navigation.
class NavigateToScan extends HomeNavigationEvent {}

/// Event to navigate to the dermatologists screen in the home navigation.
class NavigateToDermatologists extends HomeNavigationEvent {}

/// Event to navigate to the slots screen in the home navigation.
class NavigateToSlots extends HomeNavigationEvent {}

/// Event to navigate to the appointments screen in the home navigation.
class NavigateToAppointments extends HomeNavigationEvent {}

/// Event to navigate to the results screen in the home navigation.
class NavigateToResults extends HomeNavigationEvent {}