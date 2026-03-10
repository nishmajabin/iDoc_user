import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Processing payment (creating order, opening Razorpay)
class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

/// Payment UI opened (Razorpay checkout displayed)
class PaymentUIOpened extends PaymentState {
  const PaymentUIOpened();
}

/// Payment succeeded and appointment is being saved
class PaymentSuccessProcessing extends PaymentState {
  final String paymentId;
  final String orderId;

  const PaymentSuccessProcessing({
    required this.paymentId,
    required this.orderId,
  });

  @override
  List<Object?> get props => [paymentId, orderId];
}

/// Payment succeeded and appointment saved successfully
class PaymentAndBookingSuccess extends PaymentState {
  final String appointmentId;
  final String paymentId;
  final String orderId;
  final String doctorName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;

  const PaymentAndBookingSuccess({
    required this.appointmentId,
    required this.paymentId,
    required this.orderId,
    required this.doctorName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        paymentId,
        orderId,
        doctorName,
        appointmentDate,
        startTime,
        endTime,
      ];
}

/// Payment failed
class PaymentFailed extends PaymentState {
  final String message;
  final int? errorCode;

  const PaymentFailed({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Payment cancelled by user
class PaymentCancelled extends PaymentState {
  const PaymentCancelled();
}

/// Error during payment or booking process
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}