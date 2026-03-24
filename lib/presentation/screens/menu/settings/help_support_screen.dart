import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 22),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Help & Support',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3)),
                          Text("We're here to help you",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                physics: const BouncingScrollPhysics(),
                children: [
                  _SectionLabel('Contact Us'),
                  const SizedBox(height: 10),
                  _ContactGrid(),
                  const SizedBox(height: 28),
                  _SectionLabel('Frequently Asked Questions'),
                  const SizedBox(height: 10),
                  ..._faqs.map((faq) => _FaqTile(faq: faq)),
                  const SizedBox(height: 28),
                  _StillNeedHelpBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _faqs = [
    _Faq(
      q: 'How do I book an appointment?',
      a: 'Go to the Home screen, browse or search for a doctor, tap their profile, select an available time slot, and confirm your booking. You\'ll receive a push notification with your appointment details.',
    ),
    _Faq(
      q: 'Can I reschedule or cancel an appointment?',
      a: 'Yes. Navigate to My Appointments, select the appointment, and tap "Reschedule" or "Cancel". Cancellations made at least 2 hours before the scheduled time are fully refunded.',
    ),
    _Faq(
      q: 'How do video consultations work?',
      a: 'At the scheduled time, open the app and tap "Join Call" on your appointment card. Ensure your camera and microphone permissions are enabled in your device settings.',
    ),
    _Faq(
      q: 'Is my health data secure?',
      a: 'Absolutely. All health data is encrypted using AES-256 and stored on ISO 27001 certified servers. We never sell your personal or health data to third parties.',
    ),
    _Faq(
      q: 'What payment methods are supported?',
      a: 'We accept all major credit/debit cards, UPI, net banking, and popular wallets. All transactions are processed via our PCI-DSS compliant payment gateway.',
    ),
    _Faq(
      q: 'How do I view my prescriptions?',
      a: 'After a consultation, your doctor may upload a digital prescription. Find it in My Appointments → select the appointment → Prescription tab.',
    ),
  ];
}

// ── Contact Grid ──────────────────────────────────────────────────────────────

class _ContactGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _ContactItem(
        icon: Icons.chat_bubble_rounded,
        iconColor: AppColors.primary,
        iconBg: AppColors.primarySurface,
        label: 'Live Chat',
        subtitle: 'Available 9am–9pm',
        onTap: () {
          // TODO: open in-app chat support
        },
      ),
      _ContactItem(
        icon: Icons.email_rounded,
        iconColor: AppColors.completed,
        iconBg: AppColors.completedSurface,
        label: 'Email Us',
        subtitle: 'support@idoc.app',
        onTap: () async {
          final uri = Uri.parse(
              'mailto:support@idoc.app?subject=iDoc Support');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
      _ContactItem(
        icon: Icons.phone_rounded,
        iconColor: AppColors.confirmed,
        iconBg: AppColors.confirmedSurface,
        label: 'Call Us',
        subtitle: '+91 484 000 0000',
        onTap: () async {
          final uri = Uri.parse('tel:+914840000000');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
      _ContactItem(
        icon: Icons.public_rounded,
        iconColor: AppColors.pending,
        iconBg: AppColors.pendingSurface,
        label: 'Help Center',
        subtitle: 'Browse articles',
        onTap: () async {
          final uri = Uri.parse('https://help.idoc.app');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri,
                mode: LaunchMode.externalApplication);
          }
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items,
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── FAQ ───────────────────────────────────────────────────────────────────────

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _open = v),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          trailing: AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted),
          ),
          title: Text(
            widget.faq.q,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          children: [
            Text(
              widget.faq.a,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Still Need Help banner ────────────────────────────────────────────────────

class _StillNeedHelpBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Still need help?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                  'Our support team typically responds within 2 hours.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Chat Now',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      );
}