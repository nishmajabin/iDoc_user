import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/my_appointment/appointment_shimmer_cubit.dart';

class MyAppointmentShimmerCard extends StatelessWidget {
  const MyAppointmentShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShimmerCubit, double>(
      builder: (context, animValue) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(46, 46, animValue, radius: 23),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(14, 140, animValue),
                      const SizedBox(height: 8),
                      _shimmerBox(12, 90, animValue),
                    ],
                  ),
                ),
                _shimmerBox(24, 80, animValue, radius: 12),
              ],
            ),
            const SizedBox(height: 16),
            _shimmerBox(1, double.infinity, animValue),
            const SizedBox(height: 16),
            Row(
              children: [
                _shimmerBox(30, 110, animValue, radius: 10),
                const SizedBox(width: 10),
                _shimmerBox(30, 90, animValue, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, double animValue,
      {double radius = 6}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(animValue - 1, 0),
          end: Alignment(animValue, 0),
          colors: const [
            AppColors.shimmerBase,
            Color(0xFFF5F9FF),
            AppColors.shimmerBase,
          ],
        ),
      ),
    );
  }
}