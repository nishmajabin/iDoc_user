import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_contact_item.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportContactGrid extends StatelessWidget {
  const HelpSupportContactGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      HelpSupportContactItem(
        icon: Icons.email_rounded,
        iconColor: AppColors.completed,
        iconBg: AppColors.completedSurface,
        label: 'Email Us',
        subtitle: 'support@idoc.app',
        onTap: () async {
          final uri =
              Uri.parse('mailto:support@idoc.app?subject=iDoc Support');
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
      HelpSupportContactItem(
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