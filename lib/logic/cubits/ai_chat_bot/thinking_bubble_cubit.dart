import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/ai_chat_bot/thinking_bubbler_state.dart';

class ThinkingBubbleCubit extends Cubit<ThinkingBubbleState> {
  ThinkingBubbleCubit() : super(ThinkingBubbleState.initial()) {
    _startLoop();
  }

  static const _dotCount    = 3;
  static const _peakOffset  = -7.0;
  static const _stepDelay   = Duration(milliseconds: 140);
  static const _holdDelay   = Duration(milliseconds: 300);
  static const _resetDelay  = Duration(milliseconds: 350);
  static const _animStep    = Duration(milliseconds: 16); // ~60 fps

  bool _running = true;

  Future<void> _startLoop() async {
    while (_running) {
      // ── Rise: animate each dot up one by one ──────────────────────
      for (int i = 0; i < _dotCount; i++) {
        if (!_running) return;
        await _animateDot(i, from: 0.0, to: _peakOffset);
        await _delay(_stepDelay);
      }

      // ── Hold at peak ───────────────────────────────────────────────
      await _delay(_holdDelay);

      // ── Fall: animate all dots down together ───────────────────────
      await _animateAll(from: _peakOffset, to: 0.0);

      // ── Pause before next cycle ────────────────────────────────────
      await _delay(_resetDelay);
    }
  }

  /// Smoothly animates a single dot [index] from [from] to [to].
  Future<void> _animateDot(int index, {
    required double from,
    required double to,
  }) async {
    const steps    = 15; // ~240 ms at 16 ms/step
    final delta    = (to - from) / steps;
    double current = from;

    for (int s = 0; s < steps; s++) {
      if (!_running) return;
      current += delta;
      final updated = List<double>.from(state.offsets);
      updated[index] = current.clamp(
        _peakOffset < 0 ? _peakOffset : 0.0,
        _peakOffset < 0 ? 0.0 : _peakOffset,
      );
      emit(state.copyWith(offsets: updated));
      await _delay(_animStep);
    }

    // Snap to exact target to avoid float drift
    final snapped = List<double>.from(state.offsets);
    snapped[index] = to;
    emit(state.copyWith(offsets: snapped));
  }

  /// Smoothly animates all dots together from [from] to [to].
  Future<void> _animateAll({
    required double from,
    required double to,
  }) async {
    const steps    = 15;
    final delta    = (to - from) / steps;
    double current = from;

    for (int s = 0; s < steps; s++) {
      if (!_running) return;
      current += delta;
      final clamped = current.clamp(
        _peakOffset < 0 ? _peakOffset : 0.0,
        _peakOffset < 0 ? 0.0 : _peakOffset,
      );
      emit(state.copyWith(
        offsets: List.filled(_dotCount, clamped),
      ));
      await _delay(_animStep);
    }

    emit(state.copyWith(offsets: List.filled(_dotCount, to)));
  }

  Future<void> _delay(Duration duration) async {
    if (!_running) return;
    await Future.delayed(duration);
  }

  @override
  Future<void> close() {
    _running = false;
    return super.close();
  }
}