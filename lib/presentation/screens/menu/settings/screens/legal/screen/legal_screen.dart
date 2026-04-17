import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/legal_section_model.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/legal/widgets/legal_header.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/legal/widgets/legal_meta_banner.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/legal/widgets/legal_section_block.dart';



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
            LegalHeader(title: title, subtitle: subtitle),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 48),
                physics: const BouncingScrollPhysics(),
                itemCount: sections.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Column(
                      children: [
                        LegalMetaBanner(
                          lastUpdated: lastUpdated,
                          icon: headerIcon,
                          iconColor: iconColor,
                          iconBg: iconBg,
                        ),
                        const SizedBox(height: 18),
                      ],
                    );
                  }
                  return LegalSectionBlock(section: sections[i - 1]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
