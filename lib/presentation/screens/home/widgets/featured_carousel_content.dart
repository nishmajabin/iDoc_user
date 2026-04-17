import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_state.dart';
import 'package:idoc_user/logic/cubits/carousel/carousel_cubit.dart';
import 'package:idoc_user/logic/cubits/carousel/carousel_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_doctor_card.dart';

class FeaturedCarouselContent extends StatelessWidget {
  final FeaturedDoctorsLoaded state;

  const FeaturedCarouselContent({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarouselPageCubit>();
    final doctors = state.doctors;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            // Controller is owned and disposed by CarouselPageCubit.
            controller: cubit.pageController,
            itemCount: doctors.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: cubit.onPageChanged,
            itemBuilder: (context, index) =>
                FeaturedDoctorCard(doctor: doctors[index]),
          ),
        ),

        // Dot indicators — only rebuild this subtree on page changes.
        if (doctors.length > 1) ...[
          const SizedBox(height: 12),
          BlocBuilder<CarouselPageCubit, CarouselPageState>(
            builder: (context, pageState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  doctors.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: pageState.currentPage == index ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: pageState.currentPage == index
                          ? const Color(0xFF4A90D9)
                          : const Color(0xFF4A90D9)
                              .withValues(alpha: 0.25),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}