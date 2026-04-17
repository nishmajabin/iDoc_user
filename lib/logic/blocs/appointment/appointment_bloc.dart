import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentService _appointmentService;

  String? _patientName, _contactNumber, _description;
  DateTime? _selectedDate;
  String? _selectedSlotId, _selectedStartTime, _selectedEndTime;
  List<Map<String, dynamic>> _availableSlots = [];

  AppointmentBloc({required AppointmentService appointmentService})
      : _appointmentService = appointmentService,
        super(const AppointmentInitial()) {
    on<FetchPatientNameEvent>(_onFetchPatientName);
    on<SetPatientDetailsEvent>(_onSetPatientDetails);
    on<FetchAvailableSlotsEvent>(_onFetchAvailableSlots);
    on<FetchAvailableSlotsRangeEvent>(_onFetchAvailableSlotsRange);
    on<FetchAllAvailableSlotsEvent>(_onFetchAllAvailableSlots);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectSlotEvent>(_onSelectSlot);
    on<BookAppointmentEvent>(_onBookAppointment);
    on<ResetBookingEvent>(_onResetBooking);
    on<FetchUserAppointmentsEvent>(_onFetchUserAppointments);
    on<CancelAppointmentEvent>(_onCancelAppointment);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final parts =
          startTime.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (startTime.contains('PM') && hour != 12) hour += 12;
      else if (startTime.contains('AM') && hour == 12) hour = 0;
      final slotDT =
          DateTime(slotDate.year, slotDate.month, slotDate.day, hour, minute);
      return slotDT.isBefore(DateTime.now().add(const Duration(minutes: 5)));
    } catch (_) {
      return true;
    }
  }

  bool _isTodaySlotInPast(DateTime date, String startTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    return day.isAtSameMomentAs(today) && _isSlotInPast(date, startTime);
  }

  SlotsFetched _buildSlotsFetched({
    DateTime? date,
    String? slotId,
    String? start,
    String? end,
  }) =>
      SlotsFetched(
        slots: _availableSlots,
        selectedDate: date ?? _selectedDate!,
        patientName: _patientName,
        contactNumber: _contactNumber,
        description: _description,
        selectedSlotId: slotId,
        selectedStartTime: start,
        selectedEndTime: end,
      );

  String? _validateBooking() {
    if (_patientName == null || _patientName!.trim().isEmpty)
      return 'Patient name is required. Please go back and enter patient details.';
    if (_contactNumber == null || _contactNumber!.trim().isEmpty)
      return 'Contact number is required. Please go back and enter patient details.';
    if (_description == null || _description!.trim().isEmpty)
      return 'Description is required. Please go back and enter appointment details.';
    if (_selectedDate == null) return 'Please select an appointment date.';
    if (_selectedSlotId == null || _selectedSlotId!.trim().isEmpty)
      return 'Please select a time slot.';
    if (_selectedStartTime == null || _selectedStartTime!.trim().isEmpty)
      return 'Please select a time slot.';
    if (_selectedEndTime == null || _selectedEndTime!.trim().isEmpty)
      return 'Please select a time slot.';
    if (_isTodaySlotInPast(_selectedDate!, _selectedStartTime!))
      return 'Cannot book a time slot that has already passed. Please select a future time slot.';
    return null;
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  /// Fetches the logged-in user's name from Firestore and caches it in
  /// [_patientName] so the booking form is pre-populated automatically.
  Future<void> _onFetchPatientName(
    FetchPatientNameEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const PatientNameLoading());
    final name = await _appointmentService.getUserName(event.userId);
    if (name != null && name.trim().isNotEmpty) {
      _patientName = name.trim();
    }
    emit(PatientNameFetched(patientName: name?.trim()));
  }

  Future<void> _onSetPatientDetails(
    SetPatientDetailsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _patientName = event.patientName;
    _contactNumber = event.contactNumber;
    _description = event.description;
    emit(PatientDetailsSet(
      patientName: event.patientName,
      contactNumber: event.contactNumber,
      description: event.description,
    ));
  }

  /// Fetches all slots (available + booked) for a specific date so the
  /// slot-selection screen can render booked slots as disabled chips.
  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());
      _selectedDate = event.date;
      // ✅ Switched to inclusive fetch — returns available + booked slots.
      _availableSlots = await _appointmentService.fetchSlotsForDate(
        doctorId: event.doctorId,
        date: event.date,
      );
      emit(_buildSlotsFetched(date: event.date));
    } catch (e) {
      emit(AppointmentError('Failed to fetch slots: $e'));
    }
  }

  /// Fetches all slots (available + booked) within a date range.
  Future<void> _onFetchAvailableSlotsRange(
    FetchAvailableSlotsRangeEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());
      // ✅ Switched to inclusive fetch.
      _availableSlots = await _appointmentService.fetchSlotsForRange(
        doctorId: event.doctorId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      _selectedDate = _availableSlots.isNotEmpty
          ? _availableSlots.first['date'] as DateTime
          : event.startDate;
      emit(_buildSlotsFetched());
    } catch (e) {
      emit(AppointmentError('Failed to fetch slots: $e'));
    }
  }

  /// Fetches all future slots (available + booked) from today onwards.
  /// This is what [SlotSelectionScreen] calls via [FetchAllAvailableSlotsEvent].
  Future<void> _onFetchAllAvailableSlots(
    FetchAllAvailableSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());
      // ✅ Switched to inclusive fetch — the slot-selection screen receives
      //    both available and booked slots; booked ones are disabled in the UI.
      _availableSlots =
          await _appointmentService.fetchSlots(doctorId: event.doctorId);
      final now = DateTime.now();
      _selectedDate = _availableSlots.isNotEmpty
          ? _availableSlots.first['date'] as DateTime
          : DateTime(now.year, now.month, now.day);
      emit(_buildSlotsFetched());
    } catch (e) {
      emit(AppointmentError('Failed to fetch slots: $e'));
    }
  }

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _selectedDate = event.date;
    _selectedSlotId = _selectedStartTime = _selectedEndTime = null;
    emit(_buildSlotsFetched(date: event.date));
  }

  Future<void> _onSelectSlot(
    SelectSlotEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    if (_selectedDate != null &&
        _isTodaySlotInPast(_selectedDate!, event.startTime)) {
      emit(const AppointmentError(
          'This time slot has already passed. Please select a future time.'));
      return;
    }
    _selectedSlotId = event.slotId;
    _selectedStartTime = event.startTime;
    _selectedEndTime = event.endTime;
    if (state is SlotsFetched) {
      emit((state as SlotsFetched).copyWith(
        selectedSlotId: event.slotId,
        selectedStartTime: event.startTime,
        selectedEndTime: event.endTime,
        patientName: _patientName,
        contactNumber: _contactNumber,
        description: _description,
      ));
    }
  }

  Future<void> _onBookAppointment(
    BookAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final error = _validateBooking();
    if (error != null) {
      emit(AppointmentError(error));
      return;
    }

    try {
      emit(const AppointmentLoading());
      final appointmentId = await _appointmentService.bookAppointment(
        appointment: AppointmentModel(
          doctorId: event.doctorId,
          userId: event.userId,
          slotId: _selectedSlotId!,
          patientName: _patientName!,
          contactNumber: _contactNumber!,
          description: _description!,
          appointmentDate: _selectedDate!,
          startTime: _selectedStartTime!,
          endTime: _selectedEndTime!,
          status: 'confirmed',
          doctorName: event.doctorName,
          doctorSpecialist: event.doctorSpecialist,
          doctorProfileImageUrl: event.doctorProfileImageUrl,
        ),
      );
      emit(AppointmentBooked(
        appointmentId: appointmentId,
        doctorName: event.doctorName ?? 'Doctor',
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        appointmentDate: _selectedDate!,
      ));
    } catch (e) {
      emit(AppointmentError('Failed to book appointment: $e'));
    }
  }

  Future<void> _onResetBooking(
    ResetBookingEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _patientName = _contactNumber = _description = null;
    _selectedDate = null;
    _selectedSlotId = _selectedStartTime = _selectedEndTime = null;
    _availableSlots = [];
    emit(const AppointmentInitial());
  }

  Future<void> _onFetchUserAppointments(
    FetchUserAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());
      emit(AppointmentsLoaded(
          appointments:
              await _appointmentService.getUserAppointments(event.userId)));
    } catch (e) {
      emit(AppointmentError('Failed to load appointments: $e'));
    }
  }

  Future<void> _onCancelAppointment(
    CancelAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());
      await _appointmentService.cancelAppointment(
        appointmentId: event.appointmentId,
        doctorId: event.doctorId,
        slotId: event.slotId,
      );
      emit(const AppointmentInitial());
    } catch (e) {
      emit(AppointmentError('Failed to cancel appointment: $e'));
    }
  }
}