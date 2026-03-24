import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_bloc.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_doctor_card.dart';

class FeaturedDoctorsCarousel extends StatefulWidget {
  const FeaturedDoctorsCarousel({super.key});

  @override
  State<FeaturedDoctorsCarousel> createState() =>
      _FeaturedDoctorsCarouselState();
}

class _FeaturedDoctorsCarouselState extends State<FeaturedDoctorsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeaturedDoctorsBloc, FeaturedDoctorsState>(
      builder: (context, state) {
        if (state is FeaturedDoctorsLoading || state is FeaturedDoctorsInitial) {
          return _buildShimmerLoader();
        }

        if (state is FeaturedDoctorsError) {
          return _buildEmptyFallback();
        }

        if (state is FeaturedDoctorsEmpty) {
          return _buildEmptyFallback();
        }

        if (state is FeaturedDoctorsLoaded) {
          return _buildCarousel(state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCarousel(FeaturedDoctorsLoaded state) {
    final doctors = state.doctors;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: doctors.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return FeaturedDoctorCard(doctor: doctors[index]);
            },
          ),
        ),

        // Dot indicators
        if (doctors.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              doctors.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? const Color(0xFF4A90D9)
                      : const Color(0xFF4A90D9).withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFallback() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD5EFFF),
            Color(0xFFB3DAF1),
            Color(0xFF8EC5E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 36,
                color: Color(0xFF4A90D9),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Featured Doctors Yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Top-rated doctors will appear here',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
