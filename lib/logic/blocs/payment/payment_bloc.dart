import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/data/services/appointment_service.dart';
import 'package:idoc_user/data/services/payment_service.dart';
import 'package:idoc_user/logic/blocs/payment/payment_event.dart';
import 'package:idoc_user/logic/blocs/payment/payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentService _paymentService;
  final AppointmentService _appointmentService;

  //  Expose paymentService so screens can initialize Razorpay
  PaymentService get paymentService => _paymentService;

  // Store appointment data temporarily during payment flow
  String? _doctorId;
  String? _userId;
  String? _slotId;
  String? _patientName;
  String? _contactNumber;
  String? _description;
  DateTime? _appointmentDate;
  String? _startTime;
  String? _endTime;
  double? _consultationFee;
  String? _doctorName;
  String? _doctorSpecialist;
  String? _doctorProfileImageUrl;

  PaymentBloc({
    required PaymentService paymentService,
    required AppointmentService appointmentService,
  })  : _paymentService = paymentService,
        _appointmentService = appointmentService,
        super(const PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentFailureEvent>(_onPaymentFailure);
    on<PaymentCancelledEvent>(_onPaymentCancelled);
    on<ResetPaymentEvent>(_onResetPayment);
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      print('=== INITIATING PAYMENT ===');
      print('Amount: ₹${event.consultationFee}');
      print('Patient: ${event.patientName}');
      print('Doctor: ${event.doctorName}');
      print('========================');

      emit(const PaymentProcessing());

      // Store appointment details for later use
      _doctorId = event.doctorId;
      _userId = event.userId;
      _slotId = event.slotId;
      _patientName = event.patientName;
      _contactNumber = event.contactNumber;
      _description = event.description;
      _appointmentDate = event.appointmentDate;
      _startTime = event.startTime;
      _endTime = event.endTime;
      _consultationFee = event.consultationFee;
      _doctorName = event.doctorName;
      _doctorSpecialist = event.doctorSpecialist;
      _doctorProfileImageUrl = event.doctorProfileImageUrl;

      // Create Razorpay order
      final orderData = await _paymentService.createOrder(
        amount: event.consultationFee,
        receipt: 'appointment_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('✅ Razorpay order created: ${orderData['orderId']}');

      // Open Razorpay payment UI
      await _paymentService.openCheckout(
        orderId: orderData['orderId'],
        amount: event.consultationFee,
        name: event.patientName,
        contact: event.contactNumber,
        email: '', // Add email if available from user profile
        description: 'Consultation with Dr. ${event.doctorName}',
      );

      emit(const PaymentUIOpened());
    } catch (e, stackTrace) {
      print('❌ Error initiating payment: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError('Failed to initiate payment: ${e.toString()}'));
    }
  }

  Future<void> _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      print('=== PAYMENT SUCCESS ===');
      print('Payment ID: ${event.paymentId}');
      print('Order ID: ${event.orderId}');
      print('Signature: ${event.signature}');
      print('=====================');

      emit(PaymentSuccessProcessing(
        paymentId: event.paymentId,
        orderId: event.orderId,
      ));

      // Validate all required data is present
      if (_doctorId == null ||
          _userId == null ||
          _slotId == null ||
          _patientName == null ||
          _contactNumber == null ||
          _description == null ||
          _appointmentDate == null ||
          _startTime == null ||
          _endTime == null ||
          _consultationFee == null) {
        throw Exception('Missing required appointment data');
      }

      // Verify payment signature for security
      final isVerified = await _paymentService.verifyPaymentSignature(
        orderId: event.orderId,
        paymentId: event.paymentId,
        signature: event.signature,
      );

      if (!isVerified) {
        throw Exception('Payment signature verification failed');
      }

      print('✅ Payment signature verified');

      // Fetch user's profile image
      String? profileImageUrl;
      try {
        profileImageUrl = await _appointmentService.getUserProfileImage(_userId!);
      } catch (e) {
        print('⚠️ Warning: Failed to fetch user profile image: $e');
      }

      // Create appointment with payment details
      final appointment = AppointmentModel(
        doctorId: _doctorId!,
        userId: _userId!,
        slotId: _slotId!,
        patientName: _patientName!,
        contactNumber: _contactNumber!,
        description: _description!,
        appointmentDate: _appointmentDate!,
        startTime: _startTime!,
        endTime: _endTime!,
        status: 'confirmed',
        doctorName: _doctorName,
        doctorSpecialist: _doctorSpecialist,
        doctorProfileImageUrl: _doctorProfileImageUrl,
        profileImageUrl: profileImageUrl,
        paymentId: event.paymentId,
        orderId: event.orderId,
        consultationFee: _consultationFee!,
        paymentStatus: 'paid',
      );

      print('Creating appointment in Firestore...');

      // Save appointment to Firestore
      final appointmentId = await _appointmentService.bookAppointment(
        appointment: appointment,
      );

      print('✅ Appointment saved successfully: $appointmentId');

      emit(PaymentAndBookingSuccess(
        appointmentId: appointmentId,
        paymentId: event.paymentId,
        orderId: event.orderId,
        doctorName: _doctorName ?? 'Doctor',
        appointmentDate: _appointmentDate!,
        startTime: _startTime!,
        endTime: _endTime!,
      ));

      // Clear stored data
      _clearStoredData();
    } catch (e, stackTrace) {
      print('❌ Error processing payment success: $e');
      print('Stack trace: $stackTrace');
      
      // Clear stored data on error
      _clearStoredData();
      
      emit(PaymentError(
        'Payment successful but failed to book appointment. Please contact support with payment ID: ${event.paymentId}',
      ));
    }
  }

  Future<void> _onPaymentFailure(
    PaymentFailureEvent event,
    Emitter<PaymentState> emit,
  ) async {
    print('=== PAYMENT FAILED ===');
    print('Code: ${event.code}');
    print('Message: ${event.message}');
    print('====================');

    _clearStoredData();

    emit(PaymentFailed(
      message: event.message,
      errorCode: event.code,
    ));
  }

  Future<void> _onPaymentCancelled(
    PaymentCancelledEvent event,
    Emitter<PaymentState> emit,
  ) async {
    print('=== PAYMENT CANCELLED BY USER ===');

    _clearStoredData();

    emit(const PaymentCancelled());
  }

  Future<void> _onResetPayment(
    ResetPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    _clearStoredData();
    emit(const PaymentInitial());
  }

  void _clearStoredData() {
    _doctorId = null;
    _userId = null;
    _slotId = null;
    _patientName = null;
    _contactNumber = null;
    _description = null;
    _appointmentDate = null;
    _startTime = null;
    _endTime = null;
    _consultationFee = null;
    _doctorName = null;
    _doctorSpecialist = null;
    _doctorProfileImageUrl = null;
  }
}