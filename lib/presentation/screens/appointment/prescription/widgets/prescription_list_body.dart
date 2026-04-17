import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_bloc.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_event.dart';
import 'package:idoc_user/logic/blocs/prescription/prescription_state.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/screens/prescription_detail_screen.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/empty_prescription_view.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_card.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_list_error_view.dart';
import 'package:idoc_user/presentation/screens/appointment/prescription/widgets/prescription_shimmer.dart';

class PrescriptionListBody extends StatelessWidget {
  final String userId;
  const PrescriptionListBody({required this.userId, super.key});

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
                    return PrescriptionListErrorView(
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
                  color: AppColors.backgroundColor.withValues(alpha: 0.06),
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
                  color: AppColors.backgroundColor.withValues(alpha: 0.04),
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
                        icon:  Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.bgColor, size: 20),
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
                          color: AppColors.backgroundColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:  Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.backgroundColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Prescriptions',
                            style: TextStyle(
                              color: AppColors.bgColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your medical prescriptions',
                            style: TextStyle(
                              color: AppColors.lightText,
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