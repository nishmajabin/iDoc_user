import 'package:firebase_auth/firebase_auth.dart';
import 'package:idoc_user/data/models/user_model.dart';

abstract class SignInState {
  final bool obscurePassword;
  
  const SignInState({this.obscurePassword = true});
}

class SignInInitial extends SignInState {
  const SignInInitial({super.obscurePassword});
}

class SignInLoading extends SignInState {
  const SignInLoading({super.obscurePassword});
}

class SignInSuccess extends SignInState {
  final String message;
  final User user;
  final UserModel? userModel;

  const SignInSuccess({
    required this.message,
    required this.user,
    this.userModel,
    super.obscurePassword,
  });
}

class SignInFailure extends SignInState {
  final String error;

  const SignInFailure({
    required this.error,
    super.obscurePassword,
  });
}