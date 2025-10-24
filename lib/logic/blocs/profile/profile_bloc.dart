import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ProfileBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileFailure(error: 'No user logged in'));
        return;
      }

      final email = user.email ?? '';
      final username = email.split('@').first;

      try {
        final doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          emit(ProfileSuccess(
            name: data['name'] ?? username,
            email: email,
            mobileNumber: data['mobileNumber'] ?? '',
            address: data['address'] ?? '',
            profileImageUrl: data['profileImageUrl'],
          ));
        } else {
          emit(ProfileSuccess(
            name: user.displayName ?? username,
            email: email,
            mobileNumber: '',
            address: '',
            profileImageUrl: user.photoURL,
          ));
        }
      } catch (e) {
        emit(ProfileSuccess(
          name: user.displayName ?? username,
          email: email,
          mobileNumber: '',
          address: '',
          profileImageUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(const ProfileFailure(error: 'Failed to load profile'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        emit(const ProfileFailure(error: 'No user logged in'));
        return;
      }

      await user.updateDisplayName(event.name);

      await _firestore.collection('users').doc(user.uid).set({
        'name': event.name,
        'email': user.email,
        'mobileNumber': event.mobileNumber,
        'address': event.address,
        'profileImageUrl': event.profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(ProfileSuccess(
        name: event.name,
        email: user.email ?? '',
        mobileNumber: event.mobileNumber,
        address: event.address,
        profileImageUrl: event.profileImageUrl,
      ));
    } catch (e) {
      emit(const ProfileFailure(error: 'Failed to update profile'));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _firebaseAuth.signOut();
      emit(const LogoutSuccess());
    } catch (e) {
      emit(const ProfileFailure(error: 'Failed to logout'));
    }
  }
}