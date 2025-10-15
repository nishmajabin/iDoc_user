import 'package:equatable/equatable.dart';
abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashAnimating extends SplashState {
  final double scale;
  
  const SplashAnimating(this.scale);
  
  @override
  List<Object> get props => [scale];
}

class SplashCompleted extends SplashState {}