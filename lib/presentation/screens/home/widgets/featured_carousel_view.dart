import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_bloc.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_state.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_carousel_content.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_carousel_empty_fall_back.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_carousel_shimmer_loader.dart';

class FeaturedDoctorsCarouselView extends StatelessWidget {
  const FeaturedDoctorsCarouselView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeaturedDoctorsBloc, FeaturedDoctorsState>(
      builder: (context, state) {
        if (state is FeaturedDoctorsLoading ||
            state is FeaturedDoctorsInitial) {
          return const FeaturedCarouselShimmerLoader();
        }

        if (state is FeaturedDoctorsError ||
            state is FeaturedDoctorsEmpty) {
          return const FeaturedCarouselEmptyFallback();
        }

        if (state is FeaturedDoctorsLoaded) {
          return  FeaturedCarouselContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}