import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_event.dart';
import 'package:idoc_user/logic/blocs/appointment_list/appointment_list_state.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/presentation/screens/appointment/appointment_view_screen.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  bool isUpcoming = true;
  String? _userId;
  late final AnimationController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.uid;
      context
          .read<AppointmentsListBloc>()
          .add(FetchUserAppointmentsEvent(_userId!));
    } else {
      setState(() {});
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return _buildUnauthenticated();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 40,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Track and manage your visits',
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
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: AppColors.gradientStart,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _TabItem(
              label: 'Upcoming',
              icon: Icons.upcoming_rounded,
              isSelected: isUpcoming,
              onTap: () => setState(() => isUpcoming = true),
            ),
            _TabItem(
              label: 'Past',
              icon: Icons.history_rounded,
              isSelected: !isUpcoming,
              onTap: () => setState(() => isUpcoming = false),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return BlocConsumer<AppointmentsListBloc, AppointmentsListState>(
      listener: (context, state) {
        if (state is AppointmentCancelled) {
          _showSnackBar(context, state.message, isError: false);
        } else if (state is AppointmentsListError) {
          _showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is AppointmentsListLoading ||
            state is AppointmentCancelling) {
          return _buildShimmer();
        }

        if (state is AppointmentsListError) {
          return _buildError(state.message);
        }

        if (state is AppointmentsListLoaded) {
          final appointments = isUpcoming
              ? state.upcomingAppointments
              : state.pastAppointments;

          if (appointments.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardBg,
            onRefresh: () async {
              if (_userId != null) {
                context
                    .read<AppointmentsListBloc>()
                    .add(RefreshAppointmentsEvent(_userId!));
                await Future.delayed(const Duration(milliseconds: 500));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: appointments.length,
              itemBuilder: (context, index) => _AppointmentCard(
                appointment: appointments[index],
                isUpcoming: isUpcoming,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentViewScreen(
                      appointment: appointments[index],
                    ),
                  ),
                ),
                onCancel: () =>
                    _showCancelDialog(context, appointments[index]),
              ),
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isUpcoming
                    ? Icons.event_available_rounded
                    : Icons.history_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming
                  ? 'No Upcoming Appointments'
                  : 'No Past Appointments',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isUpcoming
                  ? 'Your upcoming scheduled visits will appear here.'
                  : 'Your appointment history will show up here.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
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
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.cancelled,
                size: 40,
              ),
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
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadAppointments,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(12),
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

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: 4,
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }

  // ── Unauthenticated ────────────────────────────────────────────────────────

  Widget _buildUnauthenticated() {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Login Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You need to be logged in to view your appointments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
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
                    alignment: Alignment.center,
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Cancel Dialog ──────────────────────────────────────────────────────────

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
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
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.cancelledSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.cancelled,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to cancel this appointment? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Keep It',
                          style: TextStyle(
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
                        Navigator.pop(dialogContext);
                        if (_userId != null) {
                          context.read<AppointmentsListBloc>().add(
                                CancelAppointmentEvent(
                                  appointmentId: appointment.appointmentId!,
                                  doctorId: appointment.doctorId,
                                  slotId: appointment.slotId,
                                  userId: _userId!,
                                ),
                              );
                        }
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cancelled,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Yes, Cancel',
                          style: TextStyle(
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

  void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? AppColors.cancelled : AppColors.completed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ── Tab Item ──────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? AppColors.gradientStart
                    : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.gradientStart
                      : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isUpcoming;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.isUpcoming,
    required this.onTap,
    required this.onCancel,
  });

  _StatusStyle get _statusStyle {
    switch (appointment.status.toLowerCase()) {
      case 'completed':
        return const _StatusStyle(
          color: AppColors.completed,
          surface: AppColors.completedSurface,
          label: 'Completed',
          icon: Icons.check_circle_rounded,
        );
      case 'cancelled':
        return const _StatusStyle(
          color: AppColors.cancelled,
          surface: AppColors.cancelledSurface,
          label: 'Cancelled',
          icon: Icons.cancel_rounded,
        );
      case 'confirmed':
        return const _StatusStyle(
          color: AppColors.confirmed,
          surface: AppColors.confirmedSurface,
          label: 'Confirmed',
          icon: Icons.event_available_rounded,
        );
      default:
        return const _StatusStyle(
          color: AppColors.pending,
          surface: AppColors.pendingSurface,
          label: 'Pending',
          icon: Icons.schedule_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle;
    final isCancelled = appointment.status.toLowerCase() == 'cancelled';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Status accent bar ─────────────────────────────────────────
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Doctor row ────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          image: (appointment.doctorProfileImageUrl !=
                                      null &&
                                  appointment.doctorProfileImageUrl!
                                      .isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(
                                      appointment.doctorProfileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (appointment.doctorProfileImageUrl == null ||
                                appointment.doctorProfileImageUrl!.isEmpty)
                            ? Center(
                                child: Text(
                                  appointment.doctorName != null &&
                                          appointment.doctorName!.isNotEmpty
                                      ? appointment.doctorName![0]
                                          .toUpperCase()
                                      : 'D',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${appointment.doctorName ?? 'Doctor'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appointment.doctorSpecialist ??
                                  'Consultation',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: style.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(style.icon, size: 12, color: style.color),
                            const SizedBox(width: 4),
                            Text(
                              style.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: style.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 14),

                  // ── Date / Time ───────────────────────────────────────
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.calendar_today_rounded,
                        value: DateFormat('dd MMM yyyy')
                            .format(appointment.appointmentDate),
                        color: AppColors.primary,
                        surface: AppColors.primarySurface,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.access_time_rounded,
                        value: appointment.startTime,
                        color: AppColors.accent,
                        surface: AppColors.confirmedSurface,
                      ),
                    ],
                  ),

                  // ── Cancel button ─────────────────────────────────────
                  if (isUpcoming && !isCancelled) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cancelledSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cancelled
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded,
                                color: AppColors.cancelled, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Cancel Appointment',
                              style: TextStyle(
                                color: AppColors.cancelled,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Tap hint ──────────────────────────────────────────
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 10, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meta Chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color surface;

  const _MetaChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Style ──────────────────────────────────────────────────────────────

class _StatusStyle {
  final Color color;
  final Color surface;
  final String label;
  final IconData icon;

  const _StatusStyle({
    required this.color,
    required this.surface,
    required this.label,
    required this.icon,
  });
}

// ── Shimmer Card ──────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(46, 46, radius: 23),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(14, 140),
                      const SizedBox(height: 8),
                      _shimmerBox(12, 90),
                    ],
                  ),
                ),
                _shimmerBox(24, 80, radius: 12),
              ],
            ),
            const SizedBox(height: 16),
            _shimmerBox(1, double.infinity),
            const SizedBox(height: 16),
            Row(
              children: [
                _shimmerBox(30, 110, radius: 10),
                const SizedBox(width: 10),
                _shimmerBox(30, 90, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 6}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(_anim.value - 1, 0),
          end: Alignment(_anim.value, 0),
          colors: const [
            AppColors.shimmerBase,
            Color(0xFFF5F9FF),
            AppColors.shimmerBase,
          ],
        ),
      ),
    );
  }
}