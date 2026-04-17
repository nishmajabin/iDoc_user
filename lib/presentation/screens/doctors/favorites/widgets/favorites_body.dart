import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_state.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_doctor_card.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_empty_state.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_shimmer_list.dart';

class FavoritesBody extends StatelessWidget {
  final FavoritesState state;
  const FavoritesBody({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    // Loading with empty list → shimmer
    if (state.status == FavoriteStatus.loading &&
        state.favoriteDoctors.isEmpty) {
      return const FavoritesShimmerList();
    }

    // Truly empty
    if (state.favoriteDoctors.isEmpty) {
      return const FavoritesEmptyState();
    }

    // Populated list
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.cardBg,
      onRefresh: () async {
        context.read<FavoritesBloc>().add(LoadFavorites());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        physics: const BouncingScrollPhysics(),
        itemCount: state.favoriteDoctors.length,
        itemBuilder: (context, index) {
          return FavoritesDoctorCard(doctor: state.favoriteDoctors[index]);
        },
      ),
    );
  }
}