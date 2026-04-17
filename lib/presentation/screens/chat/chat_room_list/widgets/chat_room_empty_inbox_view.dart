
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';

class ChatRoomEmptyInboxView extends StatelessWidget {
  const ChatRoomEmptyInboxView({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Messages Yet',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor will send you a message\nafter your appointment.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
}