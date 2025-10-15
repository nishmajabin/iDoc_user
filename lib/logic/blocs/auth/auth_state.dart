// lib/blocs/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:second_project/data/models/user_model.dart';


abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class ImageUploadSuccess extends AuthState {
  final String url;
  ImageUploadSuccess(this.url);
}
