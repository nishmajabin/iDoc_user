import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentService _appointmentService;

  // Store booking data throughout the flow
  String? _patientName;
  String? _contactNumber;
  String? _description;
  DateTime? _selectedDate;
  String? _selectedSlotId;
  String? _selectedStartTime;
  String? _selectedEndTime;
  List<Map<String, dynamic>> _availableSlots = [];

  AppointmentBloc({
    required AppointmentService appointmentService,
  })  : _appointmentService = appointmentService,
        super(const AppointmentInitial()) {
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

  Future<void> _onSetPatientDetails(
    SetPatientDetailsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _patientName = event.patientName;
    _contactNumber = event.contactNumber;
    _description = event.description;

    print('=== PATIENT DETAILS SET IN BLOC ===');
    print('Patient Name: $_patientName');
    print('Contact Number: $_contactNumber');
    print('Description: $_description');
    print('===================================');

    emit(PatientDetailsSet(
      patientName: event.patientName,
      contactNumber: event.contactNumber,
      description: event.description,
    ));
  }

  Future<void> _onFetchAvailableSlots(
    FetchAvailableSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());

      _selectedDate = event.date;

      final slots = await _appointmentService.fetchAvailableSlots(
        doctorId: event.doctorId,
        date: event.date,
      );

      _availableSlots = slots;

      print('=== SLOTS FETCHED (Single Date) ===');
      print('Total slots: ${slots.length}');
      print('Patient Name (preserved): $_patientName');
      print('Contact Number (preserved): $_contactNumber');
      print('Description (preserved): $_description');
      print('===================================');

      emit(SlotsFetched(
        slots: slots,
        selectedDate: event.date,
        patientName: _patientName,
        contactNumber: _contactNumber,
        description: _description,
      ));
    } catch (e) {
      emit(AppointmentError('Failed to fetch slots: ${e.toString()}'));
    }
  }

  Future<void> _onFetchAvailableSlotsRange(
    FetchAvailableSlotsRangeEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      print('=== BEFORE LOADING - PATIENT DETAILS ===');
      print('Patient Name: $_patientName');
      print('Contact Number: $_contactNumber');
      print('Description: $_description');
      print('=======================================');
      
      emit(const AppointmentLoading());

      final slots = await _appointmentService.fetchAvailableSlotsForRange(
        doctorId: event.doctorId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      _availableSlots = slots;
      
      if (slots.isNotEmpty) {
        _selectedDate = slots.first['date'] as DateTime;
      } else {
        _selectedDate = event.startDate;
      }

      print('=== SLOTS FETCHED (Range) ===');
      print('Total slots: ${slots.length}');
      print('Patient Name (PRESERVED): $_patientName');
      print('Contact Number (PRESERVED): $_contactNumber');
      print('Description (PRESERVED): $_description');
      print('=============================');

      emit(SlotsFetched(
        slots: slots,
        selectedDate: _selectedDate!,
        patientName: _patientName,
        contactNumber: _contactNumber,
        description: _description,
      ));
    } catch (e) {
      print('Error fetching slots range: $e');
      emit(AppointmentError('Failed to fetch slots: ${e.toString()}'));
    }
  }

  Future<void> _onFetchAllAvailableSlots(
    FetchAllAvailableSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      print('=== FETCHING ALL AVAILABLE SLOTS ===');
      
      emit(const AppointmentLoading());

      final slots = await _appointmentService.fetchAllAvailableSlots(
        doctorId: event.doctorId,
      );

      _availableSlots = slots;
      
      if (slots.isNotEmpty) {
        _selectedDate = slots.first['date'] as DateTime;
      } else {
        final now = DateTime.now();
        _selectedDate = DateTime(now.year, now.month, now.day);
      }

      print('=== ALL SLOTS FETCHED ===');
      print('Total slots: ${slots.length}');
      print('Patient Name (PRESERVED): $_patientName');
      print('Contact Number (PRESERVED): $_contactNumber');
      print('Description (PRESERVED): $_description');
      print('========================');

      emit(SlotsFetched(
        slots: slots,
        selectedDate: _selectedDate!,
        patientName: _patientName,
        contactNumber: _contactNumber,
        description: _description,
      ));
    } catch (e) {
      print('Error fetching all available slots: $e');
      emit(AppointmentError('Failed to fetch slots: ${e.toString()}'));
    }
  }

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _selectedDate = event.date;
    
    // Clear selected slot when changing date
    _selectedSlotId = null;
    _selectedStartTime = null;
    _selectedEndTime = null;

    print('=== DATE SELECTED ===');
    print('Selected Date: $_selectedDate');
    print('Patient Name (preserved): $_patientName');
    print('Contact Number (preserved): $_contactNumber');
    print('Description (preserved): $_description');
    print('Slot selection cleared');
    print('====================');

    emit(SlotsFetched(
      slots: _availableSlots,
      selectedDate: event.date,
      patientName: _patientName,
      contactNumber: _contactNumber,
      description: _description,
      selectedSlotId: null,
      selectedStartTime: null,
      selectedEndTime: null,
    ));
  }

  Future<void> _onSelectSlot(
    SelectSlotEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _selectedSlotId = event.slotId;
    _selectedStartTime = event.startTime;
    _selectedEndTime = event.endTime;

    print('=== SLOT SELECTED ===');
    print('Slot ID: $_selectedSlotId');
    print('Start Time: $_selectedStartTime');
    print('End Time: $_selectedEndTime');
    print('Patient Name (preserved): $_patientName');
    print('Contact Number (preserved): $_contactNumber');
    print('Description (preserved): $_description');
    print('====================');

    if (state is SlotsFetched) {
      final currentState = state as SlotsFetched;
      emit(currentState.copyWith(
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
    try {
      print('=== BOOKING APPOINTMENT ===');
      print('Patient Name: $_patientName');
      print('Contact Number: $_contactNumber');
      print('Description: $_description');
      print('Selected Date: $_selectedDate');
      print('Selected Slot ID: $_selectedSlotId');
      print('Selected Start Time: $_selectedStartTime');
      print('Selected End Time: $_selectedEndTime');
      print('Doctor ID: ${event.doctorId}');
      print('User ID: ${event.userId}');
      print('==========================');

      // Validate all required fields
      if (_patientName == null || _patientName!.trim().isEmpty) {
        print('❌ ERROR: Patient Name is missing');
        emit(const AppointmentError('Patient name is required. Please go back and enter patient details.'));
        return;
      }
      
      if (_contactNumber == null || _contactNumber!.trim().isEmpty) {
        print('❌ ERROR: Contact Number is missing');
        emit(const AppointmentError('Contact number is required. Please go back and enter patient details.'));
        return;
      }
      
      if (_description == null || _description!.trim().isEmpty) {
        print('❌ ERROR: Description is missing');
        emit(const AppointmentError('Description is required. Please go back and enter appointment details.'));
        return;
      }
      
      if (_selectedDate == null) {
        print('❌ ERROR: Appointment Date is missing');
        emit(const AppointmentError('Please select an appointment date.'));
        return;
      }
      
      if (_selectedSlotId == null || _selectedSlotId!.trim().isEmpty) {
        print('❌ ERROR: Slot ID is missing');
        emit(const AppointmentError('Please select a time slot.'));
        return;
      }
      
      if (_selectedStartTime == null || _selectedStartTime!.trim().isEmpty) {
        print('❌ ERROR: Start Time is missing');
        emit(const AppointmentError('Please select a time slot.'));
        return;
      }
      
      if (_selectedEndTime == null || _selectedEndTime!.trim().isEmpty) {
        print('❌ ERROR: End Time is missing');
        emit(const AppointmentError('Please select a time slot.'));
        return;
      }

      emit(const AppointmentLoading());

      final appointment = AppointmentModel(
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
      );

      print('Attempting to book appointment...');

      final appointmentId = await _appointmentService.bookAppointment(
        appointment: appointment,
      );

      print('✅ Appointment booked successfully with ID: $appointmentId');

      emit(AppointmentBooked(
        appointmentId: appointmentId,
        doctorName: event.doctorName ?? 'Doctor',
        startTime: _selectedStartTime!,
        endTime: _selectedEndTime!,
        appointmentDate: _selectedDate!,
      ));
    } catch (e, stackTrace) {
      print('❌ ERROR booking appointment: $e');
      print('Stack trace: $stackTrace');
      emit(AppointmentError('Failed to book appointment: ${e.toString()}'));
    }
  }

  Future<void> _onResetBooking(
    ResetBookingEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    _patientName = null;
    _contactNumber = null;
    _description = null;
    _selectedDate = null;
    _selectedSlotId = null;
    _selectedStartTime = null;
    _selectedEndTime = null;
    _availableSlots = [];

    emit(const AppointmentInitial());
  }

  Future<void> _onFetchUserAppointments(
    FetchUserAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      emit(const AppointmentLoading());

      final appointments = await _appointmentService.getUserAppointments(event.userId);

      emit(AppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError('Failed to load appointments: ${e.toString()}'));
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
      emit(AppointmentError('Failed to cancel appointment: ${e.toString()}'));
    }
  }
}