import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class EmailChanged extends ForgotPasswordEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SendResetLinkPressed extends ForgotPasswordEvent {
  const SendResetLinkPressed();
}

class ResetState extends ForgotPasswordEvent {
  const ResetState();
}