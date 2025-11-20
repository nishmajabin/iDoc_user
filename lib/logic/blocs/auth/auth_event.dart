import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthStateChanged extends AuthEvent {
  final User? user;
  const AuthStateChanged(this.user);
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
