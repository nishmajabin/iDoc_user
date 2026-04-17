import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_contact_grid.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_faq.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_faq_tile.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_header.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_section_label.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    HelpSupportFaq(
      q: 'How do I book an appointment?',
      a: "Go to the Home screen, browse or search for a doctor, tap their profile, select an available time slot, and confirm your booking. You'll receive a push notification with your appointment details.",
    ),
    HelpSupportFaq(
      q: 'Can I reschedule or cancel an appointment?',
      a: 'Yes. Navigate to My Appointments, select the appointment, and tap "Reschedule" or "Cancel". Cancellations made at least 2 hours before the scheduled time are fully refunded.',
    ),
    HelpSupportFaq(
      q: 'How do video consultations work?',
      a: 'At the scheduled time, open the app and tap "Join Call" on your appointment card. Ensure your camera and microphone permissions are enabled in your device settings.',
    ),
    HelpSupportFaq(
      q: 'Is my health data secure?',
      a: 'Absolutely. All health data is encrypted using AES-256 and stored on ISO 27001 certified servers. We never sell your personal or health data to third parties.',
    ),
    HelpSupportFaq(
      q: 'What payment methods are supported?',
      a: 'We accept all major credit/debit cards, UPI, net banking, and popular wallets. All transactions are processed via our PCI-DSS compliant payment gateway.',
    ),
    HelpSupportFaq(
      q: 'How do I view my prescriptions?',
      a: 'After a consultation, your doctor may upload a digital prescription. Find it in My Appointments → select the appointment → Prescription tab.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            const HelpSupportHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                physics: const BouncingScrollPhysics(),
                children: [
                  const HelpSupportSectionLabel('Contact Us'),
                  const SizedBox(height: 10),
                  const HelpSupportContactGrid(),
                  const SizedBox(height: 28),
                  const HelpSupportSectionLabel('Frequently Asked Questions'),
                  const SizedBox(height: 10),
                  ..._faqs.map((faq) => HelpSupportFaqTile(faq: faq)),
                  const SizedBox(height: 28),
                  const HelpSupportSectionLabel('Still Need Help?'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
