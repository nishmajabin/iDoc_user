import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// UPDATED: Now carries the profile data while uploading
class ProfileImageUploading extends ProfileState {
  final double progress; // 0.0 to 1.0
  final ProfileSuccess currentProfile; // Keep current profile data

  const ProfileImageUploading(this.progress, this.currentProfile);

  @override
  List<Object?> get props => [progress, currentProfile];
}
class ProfileSuccess extends ProfileState {
  final String name;
  final String email;
  final String? mobileNumber;
  final String address;
  final String? profileImageUrl;

  const ProfileSuccess({
    required this.name,
    required this.email,
    this.mobileNumber,
    required this.address,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, email, mobileNumber, address, profileImageUrl];

  ProfileSuccess copyWith({
    String? name,
    String? email,
    String? mobileNumber,
    String? address,
    String? profileImageUrl,
  }) {
    return ProfileSuccess(
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}