import 'package:second_project/data/models/user_model.dart';

abstract class SignUpState {
  final bool obscurePassword;
  
  const SignUpState({this.obscurePassword = true});
}

class SignUpInitial extends SignUpState {
  const SignUpInitial({super.obscurePassword});
}

class SignUpLoading extends SignUpState {
  const SignUpLoading({super.obscurePassword});
}

class SignUpSuccess extends SignUpState {
  final String message;
  final UserModel userModel;

  const SignUpSuccess({
    required this.message,
    required this.userModel,
    super.obscurePassword,
  });
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({
    required this.error,
    super.obscurePassword,
  });
}