import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchUserProfile extends ProfileEvent {
  const FetchUserProfile();
}

class UpdateUserProfile extends ProfileEvent {
  final String name;
  final String? mobileNumber;
  final String address;

  const UpdateUserProfile({
    required this.name,
    this.mobileNumber,
    required this.address,
  });

  @override
  List<Object> get props => [name, address];
}

class UpdateProfileImage extends ProfileEvent {
  final File imageFile;

  const UpdateProfileImage( {required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}
