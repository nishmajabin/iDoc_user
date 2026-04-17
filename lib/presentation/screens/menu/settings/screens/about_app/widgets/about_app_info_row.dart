import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';

class AboutAppInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isLink;

  const AboutAppInfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.onTap,
    this.isLink = false,
    super.key
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