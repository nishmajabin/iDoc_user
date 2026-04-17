import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class NoSlotsAvailableView extends StatelessWidget {
  final String? doctorName;

  const NoSlotsAvailableView({this.doctorName, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cancelledColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 60,
                color: AppColors.noSlotsIcon,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Slots Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextColor2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Dr. ${doctorName ?? "This doctor"} has no available appointment slots. '
              'Please check back later or contact the doctor directly.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.elevatedBgColor,
                  foregroundColor: AppColors.backgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}