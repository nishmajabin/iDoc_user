import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends ForgotPasswordState {
  final String error;

  const ForgotPasswordError(this.error);

  @override
  List<Object?> get props => [error];
}

class ForgotPasswordInputState extends ForgotPasswordState {
  final String email;
  final bool isEmailValid;

  const ForgotPasswordInputState({
    required this.email,
    required this.isEmailValid,
  });

  @override
  List<Object?> get props => [email, isEmailValid];
}
