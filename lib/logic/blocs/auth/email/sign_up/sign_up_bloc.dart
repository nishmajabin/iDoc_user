import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/data/models/user_model.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign_up/sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  SignUpBloc({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(const SignUpFailure(error: 'Passwords do not match'));
      return;
    }

    emit(const SignUpLoading());

    try {
      final userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        final fullName = '${event.firstName} ${event.lastName}';
        
        // Update display name
        await user.updateDisplayName(fullName);

        // Create UserModel
        final userModel = UserModel(
          uid: user.uid,
          name: fullName,
          email: event.email.trim(),
          mobileNumber: '',
          address: '',
          profileImageUrl: null,
        );

        // Save to Firestore using UserModel's toMap method
        await _firestore.collection('users').doc(user.uid).set(
          userModel.toMap(),
        );

        emit(SignUpSuccess(
          message: 'Account created successfully!',
          userModel: userModel,
        ));
      } else {
        emit(const SignUpFailure(error: 'Failed to create user'));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailure(error: _handleFirebaseError(e)));
    } catch (e) {
      emit(const SignUpFailure(error: 'An unexpected error occurred'));
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      default:
        return e.message ?? 'Sign up failed. Please try again.';
    }
  }
}