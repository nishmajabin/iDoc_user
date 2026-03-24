import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/constants/color.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Color iconColor;
  final Color iconBg;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.iconColor,
    required this.iconBg,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            // ── Gradient header ─────────────────────────────────────────
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3)),
                            Text(subtitle,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 48),
                physics: const BouncingScrollPhysics(),
                itemCount: sections.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Column(
                      children: [
                        _MetaBanner(
                          lastUpdated: lastUpdated,
                          icon: headerIcon,
                          iconColor: iconColor,
                          iconBg: iconBg,
                        ),
                        const SizedBox(height: 18),
                      ],
                    );
                  }
                  return _SectionBlock(section: sections[i - 1]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meta banner ───────────────────────────────────────────────────────────────

class _MetaBanner extends StatelessWidget {
  final String lastUpdated;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _MetaBanner({
    required this.lastUpdated,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please read carefully',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('Last updated: $lastUpdated',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accordion section ─────────────────────────────────────────────────────────

class _SectionBlock extends StatefulWidget {
  final LegalSection section;
  const _SectionBlock({required this.section});
  @override
  State<_SectionBlock> createState() => _SectionBlockState();
}

class _SectionBlockState extends State<_SectionBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rot;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 230));
    _rot = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.section.initiallyExpanded) {
      _open = true;
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.section.index}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.section.heading,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _rot,
                        child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted,
                            size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Body
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                    ...widget.section.paragraphs.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(p,
                            style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.65)),
                      ),
                    ),
                    if (widget.section.bullets != null)
                      ...widget.section.bullets!.map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 7, right: 9),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle),
                              ),
                              Expanded(
                                child: Text(b,
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textSecondary,
                                        height: 1.55)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class LegalSection {
  final int index;
  final String heading;
  final List<String> paragraphs;
  final List<String>? bullets;
  final bool initiallyExpanded;

  const LegalSection({
    required this.index,
    required this.heading,
    required this.paragraphs,
    this.bullets,
    this.initiallyExpanded = false,
  });
}