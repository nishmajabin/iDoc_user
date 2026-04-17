import 'package:flutter/material.dart';

class SlideInAnimator extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Duration duration;
  final Curve curve;

  const SlideInAnimator({
    super.key,
    required this.child,
    this.begin = const Offset(0, 1),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideInAnimator> createState() => _SlideInAnimatorState();
}

class _SlideInAnimatorState extends State<SlideInAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Uses [SlideTransition] driven by [_animation] — no [setState] anywhere.
  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}