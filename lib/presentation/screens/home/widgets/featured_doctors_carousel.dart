import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/carousel/carousel_cubit.dart';
import 'package:idoc_user/presentation/screens/home/widgets/featured_carousel_view.dart';

class FeaturedDoctorsCarousel extends StatelessWidget {
  const FeaturedDoctorsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarouselPageCubit(),
      child: const FeaturedDoctorsCarouselView(),
    );
  }
}
