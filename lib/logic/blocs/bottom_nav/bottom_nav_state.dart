import 'package:equatable/equatable.dart';

abstract class BottomNavState extends Equatable {
  final int currentIndex;

  const BottomNavState({required this.currentIndex});

  @override
  List<Object> get props => [currentIndex];
}

class BottomNavInitial extends BottomNavState {
  const BottomNavInitial() : super(currentIndex: 0);
}

class BottomNavChanged extends BottomNavState {
  const BottomNavChanged({required int currentIndex})
      : super(currentIndex: currentIndex);
}