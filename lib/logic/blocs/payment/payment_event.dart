import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initiate payment process
class InitiatePaymentEvent extends PaymentEvent {
  final String doctorId;
  final String userId;
  final String slotId;
  final String patientName;
  final String contactNumber;
  final String description;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final double consultationFee;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const InitiatePaymentEvent({
    required this.doctorId,
    required this.userId,
    required this.slotId,
    required this.patientName,
    required this.contactNumber,
    required this.description,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  });

  @override
  List<Object?> get props => [
        doctorId,
        userId,
        slotId,
        patientName,
        contactNumber,
        description,
        appointmentDate,
        startTime,
        endTime,
        consultationFee,
        doctorName,
        doctorSpecialist,
        doctorProfileImageUrl,
      ];
}

/// Event when payment succeeds
class PaymentSuccessEvent extends PaymentEvent {
  final String paymentId;
  final String orderId;
  final String signature;

  const PaymentSuccessEvent({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  @override
  List<Object?> get props => [paymentId, orderId, signature];
}

/// Event when payment fails
class PaymentFailureEvent extends PaymentEvent {
  final int code;
  final String message;

  const PaymentFailureEvent({
    required this.code,
    required this.message,
  });

  @override
  List<Object?> get props => [code, message];
}

/// Event when payment is cancelled by user
class PaymentCancelledEvent extends PaymentEvent {
  const PaymentCancelledEvent();
}

/// Event to reset payment state
class ResetPaymentEvent extends PaymentEvent {
  const ResetPaymentEvent();
}