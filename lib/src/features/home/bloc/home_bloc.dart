import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:genfive/src/features/home/models/home_ui.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeUi homeUi = HomeUi();

  HomeBloc() : super(HomeInitialState()) {
    on<HomeSendButtonPressedEvent>(_onSendButtonPressed);
    on<HomeSessionButtonPressedEvent>(_onSessionButtonPressed);
  }

  FutureOr<void> _onSendButtonPressed(HomeSendButtonPressedEvent event, Emitter<HomeState> emit) {
    // TODO: Implement OnSendButtonPressed Function
  }

  FutureOr<void> _onSessionButtonPressed(HomeSessionButtonPressedEvent event, Emitter<HomeState> emit) {
    // TODO: Implement OnSessionButtonPressed Function
  }
}
