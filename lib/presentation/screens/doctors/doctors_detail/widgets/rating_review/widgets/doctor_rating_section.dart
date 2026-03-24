import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/data/models/rating_model.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_bloc.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_event.dart';
import 'package:idoc_user/logic/blocs/doctor_rating/doctor_rating_state.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_dialog.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_display.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_review/all_reviews_screen.dart';
import 'package:intl/intl.dart';

// ─── Entry Point ──────────────────────────────────────────────────────────────
class DoctorRatingSection extends StatelessWidget {
  final DoctorModel doctor;
  const DoctorRatingSection({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorRatingBloc()
        ..add(LoadDoctorRatings(
          doctorId: doctor.id!,
          userId: FirebaseAuth.instance.currentUser?.uid,
        )),
      child: _DoctorRatingSectionView(doctor: doctor),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────
class _DoctorRatingSectionView extends StatelessWidget {
  final DoctorModel doctor;
  const _DoctorRatingSectionView({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorRatingBloc, DoctorRatingState>(
      listenWhen: (_, curr) =>
          curr is DoctorRatingLoaded && curr.submitSuccess != null,
      listener: (context, state) {
        if (state is DoctorRatingLoaded && state.submitSuccess != null) {
          final success = state.submitSuccess!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    success
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    success
                        ? 'Rating submitted successfully!'
                        : 'Failed to submit rating. Please try again.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
              backgroundColor:
                  success ? AppColors.completed : AppColors.cancelled,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RatingHeader(doctor: doctor, state: state),
            const SizedBox(height: 16),
            if (state is DoctorRatingLoading)
              const _RatingShimmer()
            else if (state is DoctorRatingError)
              _RatingErrorView(
                message: state.message,
                onRetry: () => context.read<DoctorRatingBloc>().add(
                      LoadDoctorRatings(
                        doctorId: doctor.id!,
                        userId: FirebaseAuth.instance.currentUser?.uid,
                      ),
                    ),
              )
            else if (state is DoctorRatingLoaded) ...[
              if (state.userRating != null)
                _UserRatingBadge(userRating: state.userRating!),
              if (state.previewReviews.isEmpty)
                _NoReviewsView(doctor: doctor)
              else ...[
                ...state.previewReviews.map((r) => ReviewCard(review: r)),
                const SizedBox(height: 4),
                if (state.hasMore)
                  _SeeAllButton(
                    doctorId: doctor.id!,
                    doctorName: doctor.name,
                  ),
              ],
            ],
          ],
        );
      },
    );
  }
}

// ─── Rating Header ────────────────────────────────────────────────────────────
class _RatingHeader extends StatelessWidget {
  final DoctorModel doctor;
  final DoctorRatingState state;
  const _RatingHeader({required this.doctor, required this.state});

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        state is DoctorRatingLoaded && (state as DoctorRatingLoaded).isSubmitting;
    final userRating =
        state is DoctorRatingLoaded ? (state as DoctorRatingLoaded).userRating : null;
    final hasConsultation = state is DoctorRatingLoaded
        ? (state as DoctorRatingLoaded).hasCompletedConsultation
        : false;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.07),
                AppColors.accent.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ratings & Reviews',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingDisplay(
                    rating: doctor.averageRating,
                    totalRatings: doctor.totalRatings,
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              _RateButton(
                isSubmitting: isSubmitting,
                userRating: userRating,
                isEnabled: hasConsultation,
                onTap: () => _showRatingDialog(context, userRating),
                onDisabledTap: () => _showConsultationRequiredSnackBar(context),
              ),
            ],
          ),
        ),
        // Show informational banner when user hasn't completed a consultation
        if (state is DoctorRatingLoaded && !hasConsultation)
          const _ConsultationRequiredBanner(),
      ],
    );
  }

  void _showConsultationRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You can rate this doctor after your consultation time ends.',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pending,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, RatingModel? existing) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to rate this doctor',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.pending,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => RatingDialog(
        initialRating: existing?.rating,
        initialReview: existing?.review,
        onSubmit: (rating, review) {
          context.read<DoctorRatingBloc>().add(SubmitDoctorRating(
                doctorId: doctor.id!,
                userId: userId,
                rating: rating,
                review: review,
              ));
        },
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final bool isSubmitting;
  final RatingModel? userRating;
  final bool isEnabled;
  final VoidCallback onTap;
  final VoidCallback onDisabledTap;
  const _RateButton({
    required this.isSubmitting,
    required this.userRating,
    required this.isEnabled,
    required this.onTap,
    required this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool canTap = isEnabled && !isSubmitting;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: ElevatedButton.icon(
        onPressed: canTap
            ? onTap
            : (isSubmitting ? null : onDisabledTap),
        icon: isSubmitting
            ? const SizedBox(
                width: 15, height: 15,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                isEnabled
                    ? (userRating != null
                        ? Icons.edit_rounded
                        : Icons.star_rounded)
                    : Icons.lock_outline_rounded,
                size: 17,
              ),
        label: Text(
          isEnabled
              ? (userRating != null ? 'Edit' : 'Rate')
              : 'Rate',
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.primary : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Consultation Required Banner ─────────────────────────────────────────────
class _ConsultationRequiredBanner extends StatelessWidget {
  const _ConsultationRequiredBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.pending.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pending.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.pending),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can rate this doctor after your consultation time has ended.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User's own rating badge ──────────────────────────────────────────────────
class _UserRatingBadge extends StatelessWidget {
  final RatingModel userRating;
  const _UserRatingBadge({required this.userRating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.confirmedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.confirmed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user_rounded,
              size: 15, color: AppColors.confirmed),
          const SizedBox(width: 8),
          Text('Your rating: ',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
          ...List.generate(
            5,
            (i) => Icon(
              i < userRating.rating ? Icons.star_rounded : Icons.star_border_rounded,
              size: 15,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            userRating.rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ─── Review Card (public — reused in AllReviewsScreen) ───────────────────────
class ReviewCard extends StatelessWidget {
  final RatingModel review;
  final bool compact;
  const ReviewCard({super.key, required this.review, this.compact = false});

  // Determines a consistent avatar color per user
  Color _avatarColor(String userId) {
    const colors = [
      Color(0xFF0077B6),
      Color(0xFF00B4D8),
      Color(0xFF2D9E6B),
      Color(0xFF7B2FF7),
      Color(0xFFE07B00),
      Color(0xFFD13D3D),
      Color(0xFF0096C7),
    ];
    final index = userId.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    return colors[index];
  }

  String _displayName(RatingModel review) {
    if (review.userName != null && review.userName!.trim().isNotEmpty) {
      return review.userName!.trim();
    }
    // Fallback: anonymised ID (shown only if Firestore fetch failed)
    final uid = review.userId;
    return uid.length >= 6
        ? 'User •••${uid.substring(uid.length - 4).toUpperCase()}'
        : 'User';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final name = _displayName(review);
    final color = _avatarColor(review.userId);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.055),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar: network image OR colored initial circle
                _Avatar(
                  name: name,
                  imageUrl: review.userProfileImage,
                  color: color,
                  size: 42,
                ),
                const SizedBox(width: 12),
                // Name + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(review.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Star + number chip
                _StarChip(rating: review.rating),
              ],
            ),

            const SizedBox(height: 10),

            // ── Star row ─────────────────────────────────────────────────
            Row(
              children: List.generate(5, (i) {
                if (i < review.rating.floor()) {
                  return const Icon(Icons.star_rounded,
                      size: 17, color: Colors.amber);
                } else if (i < review.rating) {
                  return const Icon(Icons.star_half_rounded,
                      size: 17, color: Colors.amber);
                }
                return Icon(Icons.star_border_rounded,
                    size: 17, color: Colors.amber.withOpacity(0.35));
              }),
            ),

            // ── Review text ──────────────────────────────────────────────
            if (review.review != null && review.review!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  review.review!.trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Avatar widget ────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final Color color;
  final double size;
  const _Avatar({
    required this.name,
    required this.imageUrl,
    required this.color,
    required this.size,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? Colors.transparent : color.withOpacity(0.15),
        border: Border.all(
            color: color.withOpacity(0.25), width: 1.5),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialFallback(
                    initials: _initials(name), color: color, size: size),
              )
            : _InitialFallback(
                initials: _initials(name), color: color, size: size),
      ),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  const _InitialFallback(
      {required this.initials, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      color: color.withOpacity(0.12),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: size * 0.33,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ─── Star chip ────────────────────────────────────────────────────────────────
class _StarChip extends StatelessWidget {
  final double rating;
  const _StarChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF92610A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── See All button ───────────────────────────────────────────────────────────
class _SeeAllButton extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  const _SeeAllButton({required this.doctorId, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllReviewsScreen(
              doctorId: doctorId,
              doctorName: doctorName,
            ),
          ),
        ),
        icon: const Icon(Icons.reviews_rounded, size: 17),
        label: Text(
          'See All Reviews',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─── No reviews ───────────────────────────────────────────────────────────────
class _NoReviewsView extends StatelessWidget {
  final DoctorModel doctor;
  const _NoReviewsView({required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Check if user has completed a consultation to show contextual message
    final ratingState = context.read<DoctorRatingBloc>().state;
    final hasConsultation = ratingState is DoctorRatingLoaded &&
        ratingState.hasCompletedConsultation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined,
              size: 44, color: AppColors.primary.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text('No reviews yet',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            hasConsultation
                ? 'Be the first to review Dr. ${doctor.name.split(' ').first}'
                : 'Complete a consultation to leave a review.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _RatingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _RatingErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.cancelled, size: 36),
          const SizedBox(height: 8),
          Text(message,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry',
                style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────
class _RatingShimmer extends StatelessWidget {
  const _RatingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.shimmerHighlight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 120, height: 11,
                          decoration: BoxDecoration(
                            color: AppColors.shimmerHighlight,
                            borderRadius: BorderRadius.circular(6),
                          )),
                      const SizedBox(height: 6),
                      Container(
                          width: 70, height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.shimmerHighlight,
                            borderRadius: BorderRadius.circular(6),
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 9, width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 9, width: 180,
                decoration: BoxDecoration(
                  color: AppColors.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}