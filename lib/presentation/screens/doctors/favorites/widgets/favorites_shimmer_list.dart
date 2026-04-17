import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/favourite/favourite_shimmer_cubit.dart';
import 'package:idoc_user/presentation/screens/doctors/favorites/widgets/favorites_shimmer_card.dart';

class  FavoritesShimmerList extends StatelessWidget {
  const FavoritesShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      // Each card gets its own ShimmerCubit so their sweep offsets are
      // independent (staggered shimmer effect, no synchronised flash).
      itemBuilder: (_, __) => BlocProvider(
        create: (_) =>FavouriteShimmerCubit(),
        child: const FavoritesShimmerCard(),
      ),
    );
  }
}