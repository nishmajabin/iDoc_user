import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const _version = '1.0.0';
  static const _build = '100';

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
                          Text('About App',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3)),
                          Text('Version and developer info',
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
                  // Brand card
                  _BrandCard(),
                  const SizedBox(height: 24),

                  _SectionLabel('App Info'),
                  const SizedBox(height: 10),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.tag_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySurface,
                      label: 'Version',
                      value: _version,
                    ),
                    _InfoRow(
                      icon: Icons.build_rounded,
                      iconColor: AppColors.accent,
                      iconBg: AppColors.primarySurface,
                      label: 'Build Number',
                      value: _build,
                    ),
                    _InfoRow(
                      icon: Icons.phone_android_rounded,
                      iconColor: AppColors.completed,
                      iconBg: AppColors.completedSurface,
                      label: 'Platform',
                      value: _platformName(context),
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppColors.pending,
                      iconBg: AppColors.pendingSurface,
                      label: 'Released',
                      value: 'January 2025',
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _SectionLabel('Company'),
                  const SizedBox(height: 10),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.business_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySurface,
                      label: 'Developer',
                      value: 'iDoc Health Technologies',
                    ),
                    _InfoRow(
                      icon: Icons.language_rounded,
                      iconColor: AppColors.confirmed,
                      iconBg: AppColors.confirmedSurface,
                      label: 'Website',
                      value: 'www.idoc.app',
                      isLink: true,
                      onTap: () async {
                        final uri = Uri.parse('https://www.idoc.app');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _InfoRow(
                      icon: Icons.email_rounded,
                      iconColor: AppColors.completed,
                      iconBg: AppColors.completedSurface,
                      label: 'Contact',
                      value: 'hello@idoc.app',
                      isLink: true,
                      onTap: () async {
                        final uri = Uri.parse(
                            'mailto:hello@idoc.app?subject=iDoc Inquiry');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _SectionLabel('Legal'),
                  const SizedBox(height: 10),
                  _InfoCard(items: [
                    _InfoRow(
                      icon: Icons.article_rounded,
                      iconColor: AppColors.pending,
                      iconBg: AppColors.pendingSurface,
                      label: 'Open Source Licenses',
                      value: 'View licenses',
                      isLink: true,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'iDoc',
                        applicationVersion: _version,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      '© 2025 iDoc Health Technologies.\nAll rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _platformName(BuildContext context) {
    final name = Theme.of(context).platform.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

// ── Brand card ────────────────────────────────────────────────────────────────

class _BrandCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.medical_services_rounded,
                  color: AppColors.primary, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          const Text('iDoc',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Your Health, Our Priority',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14)),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Text('Version 1.0.0',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: List.generate(items.length, (i) => Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 16,
                    color: AppColors.divider),
            ],
          )),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color:
                      isLink ? AppColors.primary : AppColors.textPrimary,
                  decoration: isLink ? TextDecoration.underline : null,
                  decorationColor: AppColors.primary,
                ),
              ),
              if (isLink) ...[
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      );
}