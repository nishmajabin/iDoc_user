
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:second_project/data/repostories/profile_repository.dart';
import 'package:second_project/logic/blocs/profile/profile_event.dart';
import 'package:second_project/logic/blocs/profile/profile_state.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({
    ProfileRepository? repository,
  })  : _repository = repository ?? ProfileRepository(),
        super(const ProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    try {
      final profile = await _repository.fetchUserProfile();
      emit(profile);
    } catch (e) {
      emit(ProfileFailure(error: 'Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileLoading());

    try {
      final currentImageUrl = currentState is ProfileSuccess 
          ? currentState.profileImageUrl 
          : null;

      final profile = await _repository.updateUserProfile(
        name: event.name,
        mobileNumber: event.mobileNumber,
        address: event.address,
        currentImageUrl: currentImageUrl,
      );
      
      emit(profile);
    } catch (e) {
      emit(ProfileFailure(error: 'Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    
    try {
      // Get current profile data
      ProfileSuccess? currentProfile = await _repository.getCurrentProfile(currentState);
      
      if (currentProfile == null) {
        emit(const ProfileFailure(error: 'Unable to get current profile'));
        return;
      }

      // Upload image and update profile
      final updatedProfile = await _repository.updateProfileImage(
        imageFile: event.imageFile,
        currentProfile: currentProfile,
        onProgress: (progress) => emit(ProfileImageUploading(progress, currentProfile)),
      );

      emit(updatedProfile);
    } catch (e) {
      // Restore previous state if available
      if (currentState is ProfileSuccess) {
        emit(currentState);
      }
      emit(ProfileFailure(error: 'Failed to upload image: ${e.toString()}'));
    }
  }
}