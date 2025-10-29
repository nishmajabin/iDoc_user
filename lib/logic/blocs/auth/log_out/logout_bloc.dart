import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_event.dart';
import 'package:second_project/logic/blocs/auth/log_out/logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  LogoutBloc({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        super(const LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LogoutState> emit,
  ) async {
    emit(const LogoutLoading());

    try {
      // Check if user is signed in with Google
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser != null) {
        // Check provider data
        final isGoogleUser = currentUser.providerData
            .any((info) => info.providerId == 'google.com');

        if (isGoogleUser) {
          // Sign out from Google first
          await _googleSignIn.signOut();
        }
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      emit(const LogoutSuccess(message: 'Logged out successfully'));
    } on FirebaseAuthException catch (e) {
      emit(LogoutFailure(error: _handleFirebaseError(e)));
    } catch (e) {
      emit(LogoutFailure(error: 'Failed to logout: ${e.toString()}'));
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Failed to logout. Please try again.';
    }
  }
}