import 'package:flutter/material.dart';

/// Full-screen incoming-call overlay.
///
/// Displays the doctor's name and profile picture, with animated pulsing ring,
/// and Accept / Reject buttons.
class IncomingCallScreen extends StatefulWidget {
  final String doctorName;
  final String? doctorProfileImageUrl;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallScreen({
    super.key,
    required this.doctorName,
    this.doctorProfileImageUrl,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _slideController;
  late final Animation<double> _pulseAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── "Incoming Video Call" label ──────────────────────────
              const Text(
                'Incoming Video Call',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 28),

              // ── Animated avatar ─────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: _buildAvatar(),
              ),
              const SizedBox(height: 24),

              // ── Doctor name ─────────────────────────────────────────
              Text(
                widget.doctorName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'wants to video call you',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),

              const Spacer(flex: 3),

              // ── Accept / Reject buttons ─────────────────────────────
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.call_end_rounded,
                        label: 'Decline',
                        color: const Color(0xFFE53935),
                        onTap: widget.onReject,
                      ),
                      _ActionButton(
                        icon: Icons.videocam_rounded,
                        label: 'Accept',
                        color: const Color(0xFF43A047),
                        onTap: widget.onAccept,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: widget.doctorProfileImageUrl != null &&
                widget.doctorProfileImageUrl!.isNotEmpty
            ? Image.network(
                widget.doctorProfileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFF37474F),
      child: Center(
        child: Text(
          widget.doctorName.isNotEmpty
              ? widget.doctorName[0].toUpperCase()
              : 'D',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Action button (Accept / Decline) ────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
