import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/user_model.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_event.dart';
import 'package:idoc_user/logic/blocs/auth/email/sign_up/sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  SignUpBloc({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(SignUpFailure(
        error: 'Passwords do not match',
        obscurePassword: state.obscurePassword,
      ));
      return;
    }

    emit(SignUpLoading(obscurePassword: state.obscurePassword));

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
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
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        emit(
          SignUpSuccess(
            message: 'Account created successfully!',
            userModel: userModel,
            obscurePassword: state.obscurePassword,
          ),
        );
      } else {
        emit(SignUpFailure(
          error: 'Failed to create user',
          obscurePassword: state.obscurePassword,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailure(
        error: _handleFirebaseError(e),
        obscurePassword: state.obscurePassword,
      ));
    } catch (e) {
      emit(SignUpFailure(
        error: 'An unexpected error occurred',
        obscurePassword: state.obscurePassword,
      ));
    }
  }

  void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<SignUpState> emit,
  ) {
    final newObscureValue = !state.obscurePassword;

    if (state is SignUpLoading) {
      emit(SignUpLoading(obscurePassword: newObscureValue));
    } else if (state is SignUpFailure) {
      emit(
        SignUpFailure(
          error: (state as SignUpFailure).error,
          obscurePassword: newObscureValue,
        ),
      );
    } else if (state is SignUpSuccess) {
      emit(
        SignUpSuccess(
          message: (state as SignUpSuccess).message,
          userModel: (state as SignUpSuccess).userModel,
          obscurePassword: newObscureValue,
        ),
      );
    } else {
      emit(SignUpInitial(obscurePassword: newObscureValue));
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