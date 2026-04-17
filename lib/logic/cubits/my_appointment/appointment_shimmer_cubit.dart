// lib/logic/cubits/shimmer_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives the shimmer gradient animation value so _ShimmerCard can stay
/// a pure [StatelessWidget].
///
/// Emits a [double] sweeping continuously between -1.5 and 1.5 (matching
/// the original AnimationController tween). The cubit auto-cancels its
/// timer when [close] is called (i.e. when the BlocProvider is disposed).
class ShimmerCubit extends Cubit<double> {
  static const double _min = -1.5;
  static const double _max = 1.5;

  // Each tick advances the value by _step; at ~60 fps this takes ~1 200 ms
  // to complete one full sweep — identical to the original 1 200 ms duration.
  static const double _step = 0.05;
  static const Duration _interval = Duration(milliseconds: 16);

  Timer? _timer;
  double _current = _min;
  bool _ascending = true;

  ShimmerCubit() : super(_min) {
    _start();
  }

  void _start() {
    _timer = Timer.periodic(_interval, (_) {
      if (_ascending) {
        _current += _step;
        if (_current >= _max) _ascending = false;
      } else {
        _current -= _step;
        if (_current <= _min) _ascending = true;
      }
      emit(_current);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}