part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeSendButtonPressedEvent extends HomeEvent {}

final class HomeSessionButtonPressedEvent extends HomeEvent {}