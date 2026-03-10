import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/services/prescription_service.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_bloc.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_event.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_state.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/prescription_detail_screen.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/empty_prescription_view.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_card.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_shimmer.dart';

class PrescriptionListScreen extends StatelessWidget {
  final String userId;

  const PrescriptionListScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPrescriptionBloc(
        UserPrescriptionService(FirebaseFirestore.instance),
      )..add(FetchUserPrescriptions(userId)),
      child: _PrescriptionListBody(userId: userId),
    );
  }
}

class _PrescriptionListBody extends StatelessWidget {
  final String userId;
  const _PrescriptionListBody({required this.userId});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<UserPrescriptionBloc, UserPrescriptionState>(
                builder: (context, state) {
                  if (state is UserPrescriptionLoading) {
                    return const PrescriptionShimmer();
                  }

                  if (state is UserPrescriptionError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context
                          .read<UserPrescriptionBloc>()
                          .add(FetchUserPrescriptions(userId)),
                    );
                  }

                  if (state is UserPrescriptionLoaded) {
                    if (state.records.isEmpty) {
                      return const EmptyPrescriptionView();
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.cardBg,
                      onRefresh: () async {
                        context
                            .read<UserPrescriptionBloc>()
                            .add(RefreshUserPrescriptions(userId));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        itemCount: state.records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final record = state.records[index];
                          return PrescriptionCard(
                            record: record,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PrescriptionDetailScreen(record: record),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Content
            Column(
              children: [
                // Back button row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                // Title section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Prescriptions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your medical prescriptions',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.cancelledSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.cancelled, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}