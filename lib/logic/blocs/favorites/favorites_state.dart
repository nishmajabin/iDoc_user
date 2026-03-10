
import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

enum FavoriteStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  final List<DoctorModel> favoriteDoctors;
  final List<DoctorModel> allDoctors; // Cache all doctors to map IDs
  final FavoriteStatus status;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteIds = const [],
    this.favoriteDoctors = const [],
    this.allDoctors = const [],
    this.status = FavoriteStatus.initial,
    this.errorMessage,
  });

  bool isFavorite(String doctorId) => favoriteIds.contains(doctorId);

  FavoritesState copyWith({
    List<String>? favoriteIds,
    List<DoctorModel>? favoriteDoctors,
    List<DoctorModel>? allDoctors,
    FavoriteStatus? status,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteDoctors: favoriteDoctors ?? this.favoriteDoctors,
      allDoctors: allDoctors ?? this.allDoctors,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, favoriteDoctors, allDoctors, status, errorMessage];
}
