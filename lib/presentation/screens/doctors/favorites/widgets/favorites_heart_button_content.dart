import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/logic/blocs/favorites/favorites_bloc.dart';
import 'package:idoc_user/logic/cubits/favourite/heart_button_cubit.dart';
import 'package:idoc_user/logic/cubits/favourite/heart_button_state.dart';

class FavoritesHeartButtonContent extends StatelessWidget {
  final DoctorModel doctor;
  const FavoritesHeartButtonContent({required this.doctor, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HeartButtonCubit, HeartButtonState>(
      // Rebuild only when scale changes (avoid rebuilding on showDialog flag).
      buildWhen: (prev, curr) => prev.scale != curr.scale,
      // Show dialog only on the rising edge of showDialog.
      listenWhen: (prev, curr) => curr.showDialog && !prev.showDialog,
      listener: (context, state) {
        // Reset the flag immediately so future taps can re-trigger the dialog,
        // then open the confirmation sheet.
        context.read<HeartButtonCubit>().dismissDialog();
        _showRemoveDialog(context);
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<HeartButtonCubit>().onTap(),
          child: Transform.scale(
            scale: state.scale,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBF0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFFF6B8A),
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context) {
    // [context] here is the BlocConsumer's context, which is still inside the
    // BlocProvider tree — FavoritesBloc is accessible from within the dialog.
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFFFF6B8A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                'Remove Favourite?',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              // Body
              Text(
                'Dr. ${doctor.name} will be removed from your favourites.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Action row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogCtx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Keep',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogCtx);
                        // Use the outer BlocConsumer context — FavoritesBloc
                        // is always in scope here because our BlocProvider is
                        // an ancestor of this dialog's route.
                        context.read<FavoritesBloc>().add(
                              ToggleFavorite(doctor.id!),
                            );
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B8A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Remove',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}