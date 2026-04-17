import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_bloc.dart';
import 'package:idoc_user/logic/blocs/profile/profile_event.dart';
import 'package:idoc_user/logic/blocs/profile/profile_state.dart';
import 'edit_profile_cubit_state.dart';

class EditProfileCubit extends Cubit<EditProfileScreenState> {
  final ProfileBloc _profileBloc;

  EditProfileCubit({required ProfileBloc profileBloc})
      : _profileBloc = profileBloc,
        super(const EditProfileIdle());

  // ───────────────────────────── Public API ─────────────────────────────────

  void onProfileBlocStateChanged(ProfileState profileState) {
    if (isClosed) return;

    if (profileState is ProfileLoading) {
      emit(const EditProfileSaving());
    } else if (profileState is ProfileUpdateSuccess) {
      emit(const EditProfileSaveSuccess());
    } else if (profileState is ProfileFailure) {
      emit(EditProfileSaveFailure(profileState.error));
      // Reset to idle so the failure is only surfaced once.
      emit(const EditProfileIdle());
    }
  }

  bool saveProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    _profileBloc.add(
      UpdateUserProfile(
        name: name.trim(),
        mobileNumber: phone.trim().isEmpty ? null : phone.trim(),
        address: address.trim(),
      ),
    );
    return true;
  }

  void updateProfileImage(dynamic imageFile) {
    _profileBloc.add(UpdateProfileImage(imageFile: imageFile));
  }
}