abstract class DoctorDetailEvent {}

class LoadDoctorDetailEvent extends DoctorDetailEvent {
  final String doctorId;
  LoadDoctorDetailEvent(this.doctorId);
}

class RetryLoadDoctorDetailEvent extends DoctorDetailEvent {
  final String doctorId;
  RetryLoadDoctorDetailEvent(this.doctorId);
}