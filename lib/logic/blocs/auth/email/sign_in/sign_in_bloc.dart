import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:second_project/data/models/user_model.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_event.dart';
import 'package:second_project/logic/blocs/auth/email/sign_in/sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  SignInBloc({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const SignInInitial()) {
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignInWithGoogleSubmitted>(_onSignInWithGoogleSubmitted);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading(obscurePassword: state.obscurePassword));

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update lastLoginAt in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Fetch user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          emit(SignInSuccess(
            message: 'Login successful!',
            user: user,
            userModel: userModel,
            obscurePassword: state.obscurePassword,
          ));
        } else {
          // If document doesn't exist, emit success with just Firebase User
          emit(SignInSuccess(
            message: 'Login successful!',
            user: user,
            obscurePassword: state.obscurePassword,
          ));
        }
      } else {
        emit(SignInFailure(
          error: 'User not found!',
          obscurePassword: state.obscurePassword,
        ));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignInFailure(
        error: _handleFirebaseError(e),
        obscurePassword: state.obscurePassword,
      ));
    } catch (e) {
      log('Sign-in error: $e');
      emit(SignInFailure(
        error: 'An unexpected error occurred',
        obscurePassword: state.obscurePassword,
      ));
    }
  }

  Future<void> _onSignInWithGoogleSubmitted(
    SignInWithGoogleSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading(obscurePassword: state.obscurePassword));

    try {
      await _googleSignIn.initialize(
        serverClientId:
            "852391466375-1mkst4nnu87mcctqu0atvsf247jkkcsg.apps.googleusercontent.com",
      );

      final account = await _googleSignIn.authenticate();

      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        final String email = user.email ?? '';
        final String username = email.split('@').first;

        // Create UserModel
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? username,
          email: email,
          profileImageUrl: user.photoURL,
          mobileNumber: '',
          address: '',
        );

        // Save or update user data in Firestore using UserModel
        await _firestore.collection('users').doc(user.uid).set(
          userModel.toMap(),
          SetOptions(merge: true),
        );

        log('Google Sign-In successful: ${user.email}');
        emit(SignInSuccess(
          message: 'Google login successful!',
          user: user,
          userModel: userModel,
          obscurePassword: state.obscurePassword,
        ));
      } else {
        emit(SignInFailure(
          error: 'User not found!',
          obscurePassword: state.obscurePassword,
        ));
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        log('Sign-in cancelled by user.');
        emit(SignInFailure(
          error: 'Sign-in cancelled by user.',
          obscurePassword: state.obscurePassword,
        ));
        return;
      }
      log('Google Sign-In Exception: $e');
      emit(SignInFailure(
        error: 'Google Sign-In failed',
        obscurePassword: state.obscurePassword,
      ));
    } catch (e) {
      log('Google Sign-In error: $e');
      emit(SignInFailure(
        error: 'Google Sign-In failed',
        obscurePassword: state.obscurePassword,
      ));
    }
  }

  void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<SignInState> emit,
  ) {
    final newObscureValue = !state.obscurePassword;

    if (state is SignInLoading) {
      emit(SignInLoading(obscurePassword: newObscureValue));
    } else if (state is SignInFailure) {
      emit(
        SignInFailure(
          error: (state as SignInFailure).error,
          obscurePassword: newObscureValue,
        ),
      );
    } else if (state is SignInSuccess) {
      emit(
        SignInSuccess(
          message: (state as SignInSuccess).message,
          user: (state as SignInSuccess).user,
          userModel: (state as SignInSuccess).userModel,
          obscurePassword: newObscureValue,
        ),
      );
    } else {
      emit(SignInInitial(obscurePassword: newObscureValue));
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }
}