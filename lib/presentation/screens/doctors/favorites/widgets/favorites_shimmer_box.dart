import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/favourite/favourite_shimmer_cubit.dart';

class FavoritesShimmerBox extends StatelessWidget {
  final double h;
  final double w;
  final double radius;

  const FavoritesShimmerBox({
    required this.h,
    required this.w,
    this.radius = 8,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouriteShimmerCubit, double>(
      builder: (_, sweepPos) => Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment(sweepPos - 1, 0),
            end: Alignment(sweepPos, 0),
            colors: const [
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              AppColors.shimmerBase,
            ],
          ),
        ),
      ),
    );
  }
}