import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'legal_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Privacy Policy',
      subtitle: 'Your data, your rights',
      headerIcon: Icons.shield_rounded,
      iconColor: AppColors.completed,
      iconBg: AppColors.completedSurface,
      lastUpdated: 'January 1, 2025',
      sections: [
        LegalSection(
          index: 1,
          heading: 'Introduction',
          initiallyExpanded: true,
          paragraphs: [
            'Welcome to iDoc. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            'Please read this policy carefully. If you disagree with its terms, please discontinue use of the app.',
          ],
        ),
        LegalSection(
          index: 2,
          heading: 'Information We Collect',
          paragraphs: [
            'We collect information that you voluntarily provide to us when you register on the app, express an interest in our services, or otherwise contact us. The personal information we collect may include:',
          ],
          bullets: [
            'Full name, email address, and phone number',
            'Date of birth and gender',
            'Medical history and health-related information',
            'Payment information (processed securely via third-party providers)',
            'Profile photographs',
            'Device identifiers and usage data',
          ],
        ),
        LegalSection(
          index: 3,
          heading: 'How We Use Your Information',
          paragraphs: [
            'We use personal information collected via our app for a variety of business purposes described below, based on our legitimate business interests, in order to perform a contract with you, or for compliance with our legal obligations.',
          ],
          bullets: [
            'To facilitate appointment bookings and manage your healthcare',
            'To connect you with qualified medical professionals',
            'To send administrative information and appointment reminders',
            'To improve and personalise your experience on the platform',
            'To send you push notifications (with your permission)',
            'To comply with legal and regulatory requirements',
          ],
        ),
        LegalSection(
          index: 4,
          heading: 'Sharing Your Information',
          paragraphs: [
            'We only share information with your consent, to comply with laws, to provide you with services, or to fulfill business obligations. Specifically, we may share data with:',
          ],
          bullets: [
            'Licensed medical professionals you choose to consult',
            'Payment processors to complete transactions',
            'Cloud infrastructure providers (data encrypted at rest and in transit)',
            'Regulatory authorities when required by law',
          ],
        ),
        LegalSection(
          index: 5,
          heading: 'Data Security',
          paragraphs: [
            'We have implemented appropriate technical and organisational security measures designed to protect the security of any personal information we process. All health data is encrypted using AES-256 encryption and stored on ISO 27001 certified infrastructure.',
            'Despite our safeguards, no electronic transmission over the Internet or storage technology can be guaranteed to be 100% secure.',
          ],
        ),
        LegalSection(
          index: 6,
          heading: 'Your Privacy Rights',
          paragraphs: [
            'Depending on your location, you may have the following rights regarding your personal information:',
          ],
          bullets: [
            'Right to access your personal data we hold',
            'Right to correct inaccurate or incomplete data',
            'Right to request deletion of your personal data',
            'Right to object to or restrict certain processing',
            'Right to data portability',
            'Right to withdraw consent at any time',
          ],
        ),
        LegalSection(
          index: 7,
          heading: "Children's Privacy",
          paragraphs: [
            'Our service is not directed to children under the age of 18. We do not knowingly collect personally identifiable information from children under 18. If you are a parent or guardian and believe your child has provided us with personal data, please contact us.',
          ],
        ),
        LegalSection(
          index: 8,
          heading: 'Contact Us',
          paragraphs: [
            'If you have questions about this policy, please contact our Data Protection Officer:',
            'Email: privacy@idoc.app\nAddress: iDoc Health Technologies, 123 MedTech Park, Kochi, Kerala, India - 682030\nPhone: +91 484 000 0000',
          ],
        ),
      ],
    );
  }
}