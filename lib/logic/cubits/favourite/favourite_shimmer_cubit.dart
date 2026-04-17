import 'dart:math' show pow;

import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit that drives a repeating shimmer sweep animation.
///
/// Emits [double] values in the range [-1.5, 1.5] — identical to the original
/// [AnimationController] + [Tween] setup — but without requiring [vsync] or
/// any [StatefulWidget].
///
/// The [Ticker] is started in the constructor and disposed in [close], so
/// the animation is fully self-contained and lifecycle-safe.
///
/// Cycle duration: 1 300 ms (matching the original).
/// Easing: cubic easeInOut applied per-cycle (forward only, same as `.repeat()`
/// without `reverse: true`).
class FavouriteShimmerCubit extends Cubit<double> {
  FavouriteShimmerCubit() : super(-1.5) {
    _ticker = Ticker(_onTick)..start();
  }

  late final Ticker _ticker;

  static const _cycleDurationMs = 1300;

  void _onTick(Duration elapsed) {
    // Sawtooth progress [0, 1) that resets every cycle.
    final progress =
        (elapsed.inMilliseconds % _cycleDurationMs) / _cycleDurationMs;

    // Cubic easeInOut — same curve as the original CurvedAnimation.
    final t = progress < 0.5
        ? 2 * progress * progress
        : 1 - pow(-2 * progress + 2, 2) / 2.0;

    // Map [0, 1] → [-1.5, 1.5]
    emit(-1.5 + t * 3.0);
  }

  @override
  Future<void> close() {
    _ticker.dispose();
    return super.close();
  }
}