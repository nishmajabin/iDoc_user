import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:second_project/data/models/user_model.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {
  const SignInInitial();
}

class SignInLoading extends SignInState {
  const SignInLoading();
}

class SignInSuccess extends SignInState {
  final String message;
  final User user;
  final UserModel? userModel;  // Add this
  
  const SignInSuccess({
    required this.message,
    required this.user,
    this.userModel,  // Add this
  });
  
  @override
  List<Object> get props => [message, user];
}

class SignInFailure extends SignInState {
  final String error;

  const SignInFailure({required this.error});

  @override
  List<Object> get props => [error];
}
