import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/forgot_password/forgot_password_event.dart';
import 'package:second_project/logic/blocs/forgot_password/forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final FirebaseAuth _firebaseAuth;
  String _email = '';

  ForgotPasswordBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const ForgotPasswordInitial()) {
    on<EmailChanged>(_onEmailChanged);
    on<SendResetLinkPressed>(_onSendResetLinkPressed);
    on<ResetState>(_onResetState);
  }

  void _onEmailChanged(EmailChanged event, Emitter<ForgotPasswordState> emit) {
    _email = event.email;
    final isValid = _isValidEmail(event.email);
    emit(ForgotPasswordInputState(email: event.email, isEmailValid: isValid));
  }

  Future<void> _onSendResetLinkPressed(
    SendResetLinkPressed event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (_email.isEmpty || !_isValidEmail(_email)) {
      emit(const ForgotPasswordError('Please enter a valid email address'));
      return;
    }

    emit(const ForgotPasswordLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: _email.trim());
      emit(const ForgotPasswordSuccess(
        'Password reset link has been sent to your email',
      ));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later';
          break;
        default:
          errorMessage = 'An error occurred. Please try again';
      }
      emit(ForgotPasswordError(errorMessage));
    } catch (e) {
      emit(ForgotPasswordError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onResetState(ResetState event, Emitter<ForgotPasswordState> emit) {
    _email = '';
    emit(const ForgotPasswordInitial());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}