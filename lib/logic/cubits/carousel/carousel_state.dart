import 'package:equatable/equatable.dart';

class CarouselPageState extends Equatable {
  final int currentPage;

  const CarouselPageState({this.currentPage = 0});

  CarouselPageState copyWith({int? currentPage}) =>
      CarouselPageState(currentPage: currentPage ?? this.currentPage);

  @override
  List<Object?> get props => [currentPage];
}