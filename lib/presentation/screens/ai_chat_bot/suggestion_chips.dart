import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
         Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            'Suggested questions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.skipColor,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _SuggestionChip(
              text: suggestions[i],
              onTap: () => onTap(suggestions[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.primaryColor
              : AppColors.bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.accent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _pressed ? AppColors.bgColor : AppColors.suggestionText,
          ),
        ),
      ),
    );
  }
}