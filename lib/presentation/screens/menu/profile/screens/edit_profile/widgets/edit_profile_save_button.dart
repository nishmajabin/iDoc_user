import 'package:flutter/material.dart';

class EditProfileSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onTap;

  const EditProfileSaveButton({required this.isSaving, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaving
                ? [const Color(0xFF9DAFC2), const Color(0xFFADB8C9)]
                : [const Color(0xFF052C40), const Color(0xFF0A4A6B)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF052C40).withOpacity(0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSaving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              isSaving ? 'Saving...' : 'Save Changes',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}