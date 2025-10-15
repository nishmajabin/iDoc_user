// lib/blocs/auth/auth_event.dart

import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  SignUpEvent(this.email, this.password);
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent(this.email, this.password);
}

class SignOutEvent extends AuthEvent {}

class GoogleSignInEvent extends AuthEvent {}

class UploadImageEvent extends AuthEvent {
  final File image;
  UploadImageEvent(this.image);
}
