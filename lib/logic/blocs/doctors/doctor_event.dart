// abstract class DoctorEvent {}

// class LoadAllDoctorsEvent extends DoctorEvent {}

// class LoadDoctorsByCategoryEvent extends DoctorEvent {
//   final String category;
  
//   LoadDoctorsByCategoryEvent(this.category);
// }

// class SearchDoctorsEvent extends DoctorEvent {
//   final String query;
  
//   SearchDoctorsEvent(this.query);
// }

// class ResetSearchEvent extends DoctorEvent {}

// class RetryLoadDoctorsEvent extends DoctorEvent {}
// lib/logic/blocs/doctors/doctor_event.dart
import 'package:idoc_user/data/models/doctor_filter_model.dart';

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

// New filter events
class ApplyFiltersEvent extends DoctorEvent {
  final DoctorFilter filter;
  ApplyFiltersEvent(this.filter);
}

class ClearFiltersEvent extends DoctorEvent {}

class UpdateFilterEvent extends DoctorEvent {
  final DoctorFilter filter;
  UpdateFilterEvent(this.filter);
}