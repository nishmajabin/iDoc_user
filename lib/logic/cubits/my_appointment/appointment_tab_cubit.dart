// lib/logic/cubits/appointment_tab_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the Upcoming ↔ Past tab selection on MyAppointmentsScreen.
///
/// State: [bool]
///   true  → "Upcoming" tab is active
///   false → "Past" tab is active
class AppointmentTabCubit extends Cubit<bool> {
  AppointmentTabCubit() : super(true);

  /// Switch to the Upcoming tab.
  void selectUpcoming() {
    if (!state) emit(true);
  }

  /// Switch to the Past tab.
  void selectPast() {
    if (state) emit(false);
  }
}