import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/carousel/carousel_state.dart';

class CarouselPageCubit extends Cubit<CarouselPageState> {

  final PageController pageController =
      PageController(viewportFraction: 1.0);

  CarouselPageCubit() : super(const CarouselPageState());


  void onPageChanged(int index) {
    if (isClosed) return;
    emit(state.copyWith(currentPage: index));
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}