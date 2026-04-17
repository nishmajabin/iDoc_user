import 'package:equatable/equatable.dart';

/// Represents the local UI state for the EditProfile screen.
/// This is separate from [ProfileState] (which manages remote profile data).
/// It tracks form-saving lifecycle and is owned by [EditProfileCubit].
abstract class EditProfileScreenState extends Equatable {
  const EditProfileScreenState();

  @override
  List<Object?> get props => [];
}

/// Idle — the form is ready for user input.
class EditProfileIdle extends EditProfileScreenState {
  const EditProfileIdle();
}

/// A save request has been dispatched; show the loading indicator.
class EditProfileSaving extends EditProfileScreenState {
  const EditProfileSaving();
}

/// The save completed successfully. The screen should pop.
class EditProfileSaveSuccess extends EditProfileScreenState {
  const EditProfileSaveSuccess();
}

/// The save failed. [message] is shown in a SnackBar.
class EditProfileSaveFailure extends EditProfileScreenState {
  final String message;

  const EditProfileSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}