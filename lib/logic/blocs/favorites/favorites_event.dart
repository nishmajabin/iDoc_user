
part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class UpdateFavoritesList extends FavoritesEvent {
  final List<String> ids;
  const UpdateFavoritesList(this.ids);
  @override
  List<Object> get props => [ids];
}

class UpdateAllDoctors extends FavoritesEvent {
  final List<DoctorModel> doctors;
  const UpdateAllDoctors(this.doctors);
   @override
  List<Object> get props => [doctors];
}

class ToggleFavorite extends FavoritesEvent {
  final String doctorId;
  const ToggleFavorite(this.doctorId);
  @override
  List<Object> get props => [doctorId];
}
