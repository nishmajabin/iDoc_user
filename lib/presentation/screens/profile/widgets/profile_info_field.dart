import 'package:flutter/material.dart';

class ProfileInfoField {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;
  final Color iconColor;

  const ProfileInfoField({
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.iconColor = const Color(0xFF0096C7),
  });
}

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoField> fields;

  const ProfileInfoCard({
    super.key,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF052C40).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Column(
            children: [
              _buildField(field),
              if (index < fields.length - 1)
                Divider(
                  height: 1,
                  color: const Color(0xFFEEF2F7),
                  indent: 56,
                  endIndent: 20,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField(ProfileInfoField field) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: field.iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              field.icon,
              size: 18,
              color: field.iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9DAFC2),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  field.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: field.isPlaceholder
                        ? const Color(0xFFBDC8D5)
                        : const Color(0xFF1A2332),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}