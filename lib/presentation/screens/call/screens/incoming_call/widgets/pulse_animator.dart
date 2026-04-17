import 'package:flutter/material.dart';

class PulseAnimator extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final Curve curve;

  const PulseAnimator({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 1.15,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
  });

  @override
  State<PulseAnimator> createState() => _PulseAnimatorState();
}

class _PulseAnimatorState extends State<PulseAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Uses [AnimatedBuilder] — no [setState] anywhere.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.scale(scale: _animation.value, child: child),
      child: widget.child,
    );
  }
}