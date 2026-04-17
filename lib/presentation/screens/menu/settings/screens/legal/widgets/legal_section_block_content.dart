import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/legal_section_model.dart';
import 'package:idoc_user/logic/cubits/section_block/section_block_cubit.dart';
import 'package:idoc_user/logic/cubits/section_block/section_block_state.dart';

class LegalSectionBlockContent extends StatelessWidget {
  final LegalSection section;

  const LegalSectionBlockContent({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BlocBuilder<SectionBlockCubit, SectionBlockState>(
          builder: (context, state) {
            final isOpen = state is SectionBlockExpanded;
            return Column(
              children: [
                // ── Tappable header ────────────────────────────────────
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        context.read<SectionBlockCubit>().toggle(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${section.index}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              section.heading,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // AnimatedRotation replaces RotationTransition +
                          // AnimationController entirely — no vsync needed.
                          AnimatedRotation(
                            turns: isOpen ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 230),
                            curve: Curves.easeInOut,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Expandable body ────────────────────────────────────
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                            height: 1, color: AppColors.divider),
                        const SizedBox(height: 12),
                        ...section.paragraphs.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.65,
                              ),
                            ),
                          ),
                        ),
                        if (section.bullets != null)
                          ...section.bullets!.map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 7, right: 9),
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.textSecondary,
                                        height: 1.55,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
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