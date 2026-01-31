import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_event.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_state.dart';

class AppointmentsListBloc
    extends Bloc<AppointmentsListEvent, AppointmentsListState> {
  final AppointmentService _appointmentService;

  AppointmentsListBloc({
    required AppointmentService appointmentService,
  })  : _appointmentService = appointmentService,
        super(const AppointmentsListInitial()) {
    on<FetchUserAppointmentsEvent>(_onFetchUserAppointments);
    on<CancelAppointmentEvent>(_onCancelAppointment);
    on<RefreshAppointmentsEvent>(_onRefreshAppointments);
  }

  Future<void> _onFetchUserAppointments(
    FetchUserAppointmentsEvent event,
    Emitter<AppointmentsListState> emit,
  ) async {
    try {
      emit(const AppointmentsListLoading());

      final appointments =
          await _appointmentService.getUserAppointments(event.userId);

      final now = DateTime.now();

      final List<AppointmentModel> upcomingAppointments = [];
      final List<AppointmentModel> pastAppointments = [];

      for (final appointment in appointments) {
        final appointmentDateTime = _combineDateTime(
          appointment.appointmentDate,
          appointment.startTime,
        );

        // Cancelled always goes to past
        if (appointment.status == 'cancelled') {
          pastAppointments.add(appointment);
          continue;
        }

        if (appointmentDateTime.isAfter(now)) {
          upcomingAppointments.add(appointment);
        } else {
          pastAppointments.add(appointment);
        }
      }

      emit(AppointmentsListLoaded(
        upcomingAppointments: upcomingAppointments,
        pastAppointments: pastAppointments,
      ));
    } catch (e) {
      emit(AppointmentsListError(
        'Failed to load appointments: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCancelAppointment(
    CancelAppointmentEvent event,
    Emitter<AppointmentsListState> emit,
  ) async {
    try {
      emit(AppointmentCancelling(event.appointmentId));

      await _appointmentService.cancelAppointment(
        appointmentId: event.appointmentId,
        doctorId: event.doctorId,
        slotId: event.slotId,
      );

      add(FetchUserAppointmentsEvent(event.userId));

      emit(const AppointmentCancelled('Appointment cancelled successfully'));
    } catch (e) {
      emit(AppointmentsListError(
        'Failed to cancel appointment: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshAppointments(
    RefreshAppointmentsEvent event,
    Emitter<AppointmentsListState> emit,
  ) async {
    add(FetchUserAppointmentsEvent(event.userId));
  }

  /// ✅ FIXED: Properly handles "10:00 AM" / "03:30 PM"
  DateTime _combineDateTime(DateTime date, String time) {
    try {
      final parts = time.trim().split(' ');
      final timePart = parts[0]; // 10:00
      final period = parts.length > 1 ? parts[1].toUpperCase() : '';

      final timeSplit = timePart.split(':');
      int hour = int.parse(timeSplit[0]);
      int minute = int.parse(timeSplit[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } catch (e) {
      print('❌ Time parse failed for "$time": $e');
      return DateTime(
        date.year,
        date.month,
        date.day,
        0,
        0,
      );
    }
  }
}
