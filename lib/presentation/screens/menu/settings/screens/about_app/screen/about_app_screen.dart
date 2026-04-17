import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_bar.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_branch_card.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_info_card.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_info_row.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/about_app_section_label.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/about_app/widgets/url_launcher_helper.dart';

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
            const GradientAppBar(
              title: 'About App',
              subtitle: 'Version and developer info',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                physics: const BouncingScrollPhysics(),
                children: [
                  AboutAppBranchCard(),
                  const SizedBox(height: 24),

                  AboutAppSectionLabel('App Info'),
                  const SizedBox(height: 10),
                  AboutAppInfoCard(items: _appInfoRows(context)),

                  const SizedBox(height: 24),
                  AboutAppSectionLabel('Company'),
                  const SizedBox(height: 10),
                  AboutAppInfoCard(items: _companyRows()),

                  const SizedBox(height: 24),
                  AboutAppSectionLabel('Legal'),
                  const SizedBox(height: 10),
                  AboutAppInfoCard(items: _legalRows(context)),

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

  // ─── Row builders ──────────────────────────────────────────────────────────

  List<AboutAppInfoRow> _appInfoRows(BuildContext context) => [
        AboutAppInfoRow(
          icon: Icons.tag_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primarySurface,
          label: 'Version',
          value: _version,
        ),
        AboutAppInfoRow(
          icon: Icons.build_rounded,
          iconColor: AppColors.accent,
          iconBg: AppColors.primarySurface,
          label: 'Build Number',
          value: _build,
        ),
        AboutAppInfoRow(
          icon: Icons.phone_android_rounded,
          iconColor: AppColors.completed,
          iconBg: AppColors.completedSurface,
          label: 'Platform',
          value: _platformName(context),
        ),
        AboutAppInfoRow(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.pending,
          iconBg: AppColors.pendingSurface,
          label: 'Released',
          value: 'April 2026',
        ),
      ];

  List<AboutAppInfoRow> _companyRows() => [
        AboutAppInfoRow(
          icon: Icons.business_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primarySurface,
          label: 'Developer',
          value: 'iDoc Health Technologies',
        ),
        AboutAppInfoRow(
          icon: Icons.language_rounded,
          iconColor: AppColors.confirmed,
          iconBg: AppColors.confirmedSurface,
          label: 'Website',
          value: 'www.idoc.app',
          isLink: true,
          onTap: () => launchWebUrl('https://www.idoc.app'),
        ),
        AboutAppInfoRow(
          icon: Icons.email_rounded,
          iconColor: AppColors.completed,
          iconBg: AppColors.completedSurface,
          label: 'Contact',
          value: 'hello@idoc.app',
          isLink: true,
          onTap: () => launchMailUrl('hello@idoc.app', subject: 'iDoc Inquiry'),
        ),
      ];

  List<AboutAppInfoRow> _legalRows(BuildContext context) => [
        AboutAppInfoRow(
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
      ];

  String _platformName(BuildContext context) {
    final name = Theme.of(context).platform.name;
    return name[0].toUpperCase() + name.substring(1);
  }
}