abstract class DoctorEvent {}

class LoadAllDoctorsEvent extends DoctorEvent {}

class LoadDoctorsByCategoryEvent extends DoctorEvent {
  final String category;
  
  LoadDoctorsByCategoryEvent(this.category);
}

class SearchDoctorsEvent extends DoctorEvent {
  final String query;
  
  SearchDoctorsEvent(this.query);
}

class ResetSearchEvent extends DoctorEvent {}

class RetryLoadDoctorsEvent extends DoctorEvent {}