import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();
  
  @override
  List<Object> get props => [];
}

class StartSplash extends SplashEvent {}

class AnimationTick extends SplashEvent {
  final double scale;
  
  const AnimationTick(this.scale);
  
  @override
  List<Object> get props => [scale];
}

class CompleteSplash extends SplashEvent {}
