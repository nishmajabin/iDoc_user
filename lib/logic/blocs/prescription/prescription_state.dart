import 'package:idoc_user/data/models/prescription_model.dart';

abstract class UserPrescriptionState {
  const UserPrescriptionState();
}

class UserPrescriptionInitial extends UserPrescriptionState {}

class UserPrescriptionLoading extends UserPrescriptionState {}

class UserPrescriptionLoaded extends UserPrescriptionState {
  final List<UserPrescriptionRecord> records;
  const UserPrescriptionLoaded(this.records);
}

class UserPrescriptionError extends UserPrescriptionState {
  final String message;
  const UserPrescriptionError(this.message);
}