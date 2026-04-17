import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/favourite/heart_button_state.dart';

/// Cubit that replicates the press-and-bounce animation that was previously
/// inside [_HeartButtonState] using a raw [Ticker].
///
/// [Ticker] is a standalone Flutter class — it does NOT require a
/// [TickerProvider]/[StatefulWidget]. It runs on the engine's vsync signal,
/// giving buttery-smooth 60 fps updates exactly like [AnimationController].
///
/// Animation lifecycle:
///   onTap()  → scale 1.0 → 0.75 (180 ms, easeInOut) forward phase
///            → scale 0.75 → 1.0 (180 ms, easeInOut) reverse phase
///            → emit showDialog = true (consumed once by BlocListener)
class HeartButtonCubit extends Cubit<HeartButtonState> {
  HeartButtonCubit() : super(const HeartButtonState());

  // ── Internal animation state ───────────────────────────────────────────────

  Ticker? _ticker;
  Duration? _phaseStart; // timestamp when the current half-animation started
  bool _forward = true; // true = shrink (1.0→0.75), false = grow (0.75→1.0)

  static const _animDuration = Duration(milliseconds: 180);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Called when the user taps the heart button.
  /// Cancels any in-flight animation and restarts from the forward phase.
  void onTap() {
    _ticker?.dispose();
    _phaseStart = null;
    _forward = true;
    _ticker = Ticker(_onTick)..start();
  }

  /// Called by [BlocListener] immediately after it reads [showDialog] == true,
  /// resetting the flag so future taps can trigger the dialog again.
  void dismissDialog() {
    if (!isClosed) emit(state.copyWith(showDialog: false));
  }

  // ── Ticker callback ────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    // Latch the start timestamp for the current phase on the first tick.
    _phaseStart ??= elapsed;

    final dt = elapsed - _phaseStart!;
    final rawT = (dt.inMicroseconds / _animDuration.inMicroseconds).clamp(
      0.0,
      1.0,
    );

    // Cubic easeInOut — identical to Curves.easeInOut in Flutter.
    final t = rawT < 0.5 ? 2 * rawT * rawT : 1 - pow(-2 * rawT + 2, 2) / 2.0;

    if (_forward) {
      // Phase 1: 1.0 → 0.75
      emit(state.copyWith(scale: 1.0 - 0.25 * t));
      if (rawT >= 1.0) {
        // Switch to reverse phase
        _phaseStart = null;
        _forward = false;
      }
    } else {
      // Phase 2: 0.75 → 1.0
      emit(state.copyWith(scale: 0.75 + 0.25 * t));
      if (rawT >= 1.0) {
        // Animation complete — clean up and signal dialog.
        _ticker?.dispose();
        _ticker = null;
        emit(state.copyWith(scale: 1.0, showDialog: true));
      }
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _ticker?.dispose();
    return super.close();
  }
}
