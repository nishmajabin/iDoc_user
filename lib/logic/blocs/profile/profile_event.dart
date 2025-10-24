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
  final String? profileImageUrl;

  const UpdateUserProfile({
    required this.name,
this.mobileNumber,
    required this.address,
    this.profileImageUrl,
  });

  @override
  List<Object> get props => [name, address];
}

class LogoutUser extends ProfileEvent {
  const LogoutUser();
}