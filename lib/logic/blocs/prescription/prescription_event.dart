abstract class UserPrescriptionEvent {
  const UserPrescriptionEvent();
}

class FetchUserPrescriptions extends UserPrescriptionEvent {
  final String userId;
  const FetchUserPrescriptions(this.userId);
}

class RefreshUserPrescriptions extends UserPrescriptionEvent {
  final String userId;
  const RefreshUserPrescriptions(this.userId);
}