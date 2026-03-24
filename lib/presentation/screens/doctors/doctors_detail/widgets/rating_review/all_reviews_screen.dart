import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/rating_model.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_bloc.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_event.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_state.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_review/widgets/doctor_rating_section.dart';

class AllReviewsScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;

  const AllReviewsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorRatingBloc()
        ..add(LoadAllDoctorRatings(doctorId: doctorId)),
      child: _AllReviewsView(
          doctorId: doctorId, doctorName: doctorName),
    );
  }
}

class _AllReviewsView extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  const _AllReviewsView(
      {required this.doctorId, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Column(
          children: [
            _AppBar(doctorName: doctorName),
            Expanded(
              child: BlocBuilder<DoctorRatingBloc, DoctorRatingState>(
                builder: (context, state) {
                  if (state is DoctorRatingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }

                  if (state is DoctorRatingError) {
                    return _FullErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<DoctorRatingBloc>().add(
                                LoadAllDoctorRatings(doctorId: doctorId),
                              ),
                    );
                  }

                  if (state is AllDoctorRatingsLoaded) {
                    if (state.reviews.isEmpty) {
                      return const _EmptyReviews();
                    }
                    return _ReviewList(
                        reviews: state.reviews,
                        doctorId: doctorId);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String doctorName;
  const _AppBar({required this.doctorName});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 17),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Dr. $doctorName',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review list ──────────────────────────────────────────────────────────────
class _ReviewList extends StatelessWidget {
  final List<RatingModel> reviews;
  final String doctorId;
  const _ReviewList({required this.reviews, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    // Summary stats
    final avg = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Summary card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: _SummaryCard(
                avg: avg, total: reviews.length, reviews: reviews),
          ),
        ),
        // Review cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ReviewCard(review: reviews[i]),
              childCount: reviews.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final double avg;
  final int total;
  final List<RatingModel> reviews;
  const _SummaryCard(
      {required this.avg, required this.total, required this.reviews});

  @override
  Widget build(BuildContext context) {
    // Count per star
    final counts = List.generate(5, (i) {
      final star = 5 - i; // 5 down to 1
      return reviews.where((r) => r.rating.round() == star).length;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Big average number
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avg.floor()
                        ? Icons.star_rounded
                        : (i < avg
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded),
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total review${total == 1 ? '' : 's'}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Star breakdown bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = counts[i];
                final fraction = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 11, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: AppColors.shimmerBase,
                            valueColor: AlwaysStoppedAnimation(
                                AppColors.primary.withOpacity(0.7)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty ────────────────────────────────────────────────────────────────────
class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 60, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No reviews yet',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Be the first to share your experience',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _FullErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _FullErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.cancelled),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Retry',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}