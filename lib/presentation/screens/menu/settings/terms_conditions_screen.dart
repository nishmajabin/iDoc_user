import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'legal_screen.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScreen(
      title: 'Terms & Conditions',
      subtitle: 'Usage rules and agreements',
      headerIcon: Icons.description_rounded,
      iconColor: AppColors.accent,
      iconBg: AppColors.primarySurface,
      lastUpdated: 'January 1, 2025',
      sections: [
        LegalSection(
          index: 1,
          heading: 'Agreement to Terms',
          initiallyExpanded: true,
          paragraphs: [
            'By accessing or using the iDoc application, you agree to be bound by these Terms and Conditions and our Privacy Policy. If you do not agree to these terms, please do not use the application.',
            'We reserve the right to change or modify these terms at any time at our sole discretion. We will alert you about changes by updating the "Last updated" date of these Terms.',
          ],
        ),
        LegalSection(
          index: 2,
          heading: 'Use of the Platform',
          paragraphs: [
            'iDoc is a telemedicine platform that connects patients with licensed healthcare professionals for online consultations. The platform is intended for informational and consultative purposes only and does not replace in-person medical care.',
          ],
          bullets: [
            'You must be at least 18 years old to use this service',
            'You must register with accurate and complete information',
            'You are responsible for maintaining the security of your account',
            'You must not misuse the platform for fraudulent purposes',
            'Emergency medical situations must be directed to emergency services',
          ],
        ),
        LegalSection(
          index: 3,
          heading: 'Medical Disclaimer',
          paragraphs: [
            'The content provided through iDoc is for general informational and consultative purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment from a qualified, licensed physician.',
            'Always seek the advice of your physician or other qualified health provider with any questions you have regarding a medical condition. Never disregard professional medical advice or delay seeking it because of something you received through iDoc.',
          ],
        ),
        LegalSection(
          index: 4,
          heading: 'Appointments and Payments',
          paragraphs: [
            'Appointment bookings are subject to doctor availability. Cancellations made at least 2 hours before the scheduled appointment time are eligible for a full refund.',
          ],
          bullets: [
            'Payment is required at the time of booking',
            'Refunds are processed within 5–7 business days',
            'Late cancellations (under 2 hours) are non-refundable',
            'No-shows will be charged the full consultation fee',
            'iDoc charges a platform fee on each transaction',
          ],
        ),
        LegalSection(
          index: 5,
          heading: 'Intellectual Property',
          paragraphs: [
            'The app and its original content, features, and functionality are owned by iDoc Health Technologies and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
            'You may not reproduce, distribute, modify, create derivative works of, publicly display, or exploit any content from the platform without our prior written consent.',
          ],
        ),
        LegalSection(
          index: 6,
          heading: 'Limitation of Liability',
          paragraphs: [
            'To the maximum extent permitted by applicable law, iDoc shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or goodwill.',
            'Our total liability to you for any claim arising out of or relating to these terms or the service is limited to the amount you paid us in the 12 months preceding the claim.',
          ],
        ),
        LegalSection(
          index: 7,
          heading: 'Governing Law',
          paragraphs: [
            'These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Any disputes shall be subject to the exclusive jurisdiction of the courts of Kochi, Kerala.',
          ],
        ),
        LegalSection(
          index: 8,
          heading: 'Contact Information',
          paragraphs: [
            'For any questions regarding these Terms and Conditions, please contact us:',
            'Email: legal@idoc.app\nAddress: iDoc Health Technologies, 123 MedTech Park, Kochi, Kerala, India - 682030',
          ],
        ),
      ],
    );
  }
}