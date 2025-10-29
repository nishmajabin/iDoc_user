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
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());

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
          ));
        } else {
          // If document doesn't exist, emit success with just Firebase User
          emit(SignInSuccess(
            message: 'Login successful!',
            user: user,
          ));
        }
      } else {
        emit(const SignInFailure(error: 'User not found!'));
      }
    } on FirebaseAuthException catch (e) {
      emit(SignInFailure(error: _handleFirebaseError(e)));
    } catch (e) {
      log('Sign-in error: $e');
      emit(const SignInFailure(error: 'An unexpected error occurred'));
    }
  }

  Future<void> _onSignInWithGoogleSubmitted(
    SignInWithGoogleSubmitted event,
    Emitter<SignInState> emit,
  ) async {
    emit(const SignInLoading());

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
        ));
      } else {
        emit(const SignInFailure(error: 'User not found!'));
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        log('Sign-in cancelled by user.');
        emit(const SignInFailure(error: 'Sign-in cancelled by user.'));
        return;
      }
      log('Google Sign-In Exception: $e');
      emit(const SignInFailure(error: 'Google Sign-In failed'));
    } catch (e) {
      log('Google Sign-In error: $e');
      emit(const SignInFailure(error: 'Google Sign-In failed'));
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