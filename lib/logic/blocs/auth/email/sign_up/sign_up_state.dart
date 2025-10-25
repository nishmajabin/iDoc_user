import 'package:equatable/equatable.dart';
import 'package:second_project/data/models/user_model.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

class SignUpSuccess extends SignUpState {
  final String message;
  final UserModel? userModel;  
  
  const SignUpSuccess({
    required this.message,
    this.userModel, 
  });
  
  @override
  List<Object> get props => [message];
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({required this.error});

  @override
  List<Object> get props => [error];
}
