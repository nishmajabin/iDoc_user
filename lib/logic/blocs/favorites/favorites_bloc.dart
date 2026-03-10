
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/repostories/favorites_repository.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';
import 'favorites_state.dart';

part 'favorites_event.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _favoritesRepository;
  final DoctorRepository _doctorRepository;
  StreamSubscription? _favoritesSubscription;
  StreamSubscription? _doctorsSubscription;

  FavoritesBloc({
    required FavoritesRepository favoritesRepository,
    required DoctorRepository doctorRepository,
  })  : _favoritesRepository = favoritesRepository,
        _doctorRepository = doctorRepository,
        super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<UpdateFavoritesList>(_onUpdateFavoritesList);
    on<UpdateAllDoctors>(_onUpdateAllDoctors);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) {
    emit(state.copyWith(status: FavoriteStatus.loading));
    
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _favoritesRepository.getFavoriteIdsStream().listen(
      (ids) => add(UpdateFavoritesList(ids)),
      onError: (_) => emit(state.copyWith(status: FavoriteStatus.error, errorMessage: 'Failed to load favorites')),
    );

    _doctorsSubscription?.cancel();
    _doctorsSubscription = _doctorRepository.approvedDoctorsStream().listen(
      (doctors) => add(UpdateAllDoctors(doctors)),
      onError: (_) {}, // DoctorBloc handles main doctor errors usually
    );
  }

  void _onUpdateFavoritesList(UpdateFavoritesList event, Emitter<FavoritesState> emit) {
    final ids = event.ids;
    final favoriteDoctors = state.allDoctors.where((d) => ids.contains(d.id)).toList();
    emit(state.copyWith(
      favoriteIds: ids,
      favoriteDoctors: favoriteDoctors,
      status: FavoriteStatus.loaded,
    ));
  }

  void _onUpdateAllDoctors(UpdateAllDoctors event, Emitter<FavoritesState> emit) {
    final allDoctors = event.doctors;
    final favoriteDoctors = allDoctors.where((d) => state.favoriteIds.contains(d.id)).toList();
    emit(state.copyWith(
      allDoctors: allDoctors,
      favoriteDoctors: favoriteDoctors,
      status: FavoriteStatus.loaded,
    ));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    try {
      await _favoritesRepository.toggleFavorite(event.doctorId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update favorite'));
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    _doctorsSubscription?.cancel();
    return super.close();
  }
}
