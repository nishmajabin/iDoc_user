import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_event.dart';
import 'package:second_project/logic/blocs/bottom_nav/bottom_nav_state.dart';

class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState> {
  BottomNavBloc() : super(const BottomNavInitial()) {
    on<BottomNavTabChanged>(_onTabChanged);
    on<BottomNavReset>(_onReset);
  }

  Future<void> _onTabChanged(
    BottomNavTabChanged event,
    Emitter<BottomNavState> emit,
  ) async {
    // Store previous index before changing
    emit(BottomNavChanged(
      currentIndex: event.index,
      previousIndex: state.currentIndex,
    ));
  }

  Future<void> _onReset(
    BottomNavReset event,
    Emitter<BottomNavState> emit,
  ) async {
    emit(const BottomNavInitial());
  }
}
