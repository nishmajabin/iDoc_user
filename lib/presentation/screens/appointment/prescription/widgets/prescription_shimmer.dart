import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';

class PrescriptionShimmer extends StatefulWidget {
  const PrescriptionShimmer({super.key});

  @override
  State<PrescriptionShimmer> createState() => _PrescriptionShimmerState();
}

class _PrescriptionShimmerState extends State<PrescriptionShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
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
            children: [
              // Header shimmer
              Container(
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment(_anim.value - 1, 0),
                    end: Alignment(_anim.value, 0),
                    colors: const [
                      AppColors.shimmerBase,
                      AppColors.shimmerHighlight,
                      AppColors.shimmerBase,
                    ],
                  ),
                ),
              ),
              // Body shimmer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _box(28, 120),
                        const Spacer(),
                        _box(28, 80),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _box(26, 80),
                        const SizedBox(width: 8),
                        _box(26, 80),
                        const SizedBox(width: 8),
                        _box(26, 70),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(double h, double w, {double radius = 8}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end: Alignment(_anim.value, 0),
          colors: const [
            AppColors.shimmerBase,
            AppColors.shimmerHighlight,
            AppColors.shimmerBase,
          ],
        ),
      ),
    );
  }
}