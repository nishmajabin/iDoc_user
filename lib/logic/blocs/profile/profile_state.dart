import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
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
  List<Object> get props => [name, email, address];
}
class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}