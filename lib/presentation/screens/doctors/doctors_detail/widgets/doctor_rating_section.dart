import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/data/repostories/rate_repository.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_dialog.dart';
import 'package:idoc_user/presentation/screens/doctors/doctors_detail/widgets/rating_display.dart';

class DoctorRatingSection extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorRatingSection({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorRatingSection> createState() => _DoctorRatingSectionState();
}

class _DoctorRatingSectionState extends State<DoctorRatingSection> {
  final RatingRepository _ratingRepository = RatingRepository();
  bool _isLoading = false;
  double? _userRating;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final rating = await _ratingRepository.getUserRatingForDoctor(
      widget.doctor.id!,
      user.uid,
    );

    if (mounted) {
      setState(() {
        _userRating = rating?.rating;
        _isLoading = false;
      });
    }
  }

  Future<void> _showRatingDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to rate')),
      );
      return;
    }

    final existingRating = await _ratingRepository.getUserRatingForDoctor(
      widget.doctor.id!,
      user.uid,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        initialRating: existingRating?.rating,
        initialReview: existingRating?.review,
        onSubmit: (rating, review) async {
          await _submitRating(rating, review);
        },
      ),
    );
  }

  Future<void> _submitRating(double rating, String? review) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final success = await _ratingRepository.submitRating(
      doctorId: widget.doctor.id!,
      userId: user.uid,
      rating: rating,
      review: review,
    );

    if (mounted) {
      setState(() {
        _userRating = rating;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Rating submitted successfully'
                : 'Failed to submit rating',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Doctor Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingDisplay(
                    rating: widget.doctor.averageRating,
                    totalRatings: widget.doctor.totalRatings,
                    size: 22,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _showRatingDialog,
                icon: Icon(
                  _userRating != null ? Icons.edit : Icons.star_border,
                  size: 20,
                ),
                label: Text(
                  _userRating != null ? 'Update Rating' : 'Rate Doctor',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          if (_userRating != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You rated this doctor $_userRating stars',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}