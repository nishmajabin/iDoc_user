 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/cubits/faq_tile/faq_tile_cubit.dart';
import 'package:idoc_user/logic/cubits/faq_tile/faq_tile_state.dart';
import 'package:idoc_user/presentation/screens/menu/settings/screens/help_support/widgets/help_support_faq.dart';

class HelpSupportFaqTileContent extends StatelessWidget {
  final HelpSupportFaq faq;

  const HelpSupportFaqTileContent({required this.faq, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BlocBuilder<FaqTileCubit, FaqTileState>(
          builder: (context, state) {
            final isOpen = state is FaqTileExpanded;
            return ExpansionTile(
              onExpansionChanged: (v) =>
                  context.read<FaqTileCubit>().onExpansionChanged(v),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              childrenPadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 14),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              trailing: AnimatedRotation(
                turns: isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ),
              title: Text(
                faq.q,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              children: [
                Text(
                  faq.a,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}