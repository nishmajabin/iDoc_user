import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_event.dart';
import 'package:idoc_user/logic/blocs/auth/log_out/logout_state.dart';
import 'package:idoc_user/logic/blocs/settings/settings_bloc.dart';
import 'package:idoc_user/logic/blocs/settings/settings_event.dart';
import 'package:idoc_user/logic/blocs/settings/settings_state.dart';
import 'about_app_screen.dart';
import 'help_support_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    context.read<SettingsBloc>().add(LoadSettings(userId: widget.userId));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Settings errors (toggle save failures)
        BlocListener<SettingsBloc, SettingsState>(
          listener: (ctx, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.cancelled,
              ));
            }
          },
        ),
        // Logout result
        BlocListener<LogoutBloc, LogoutState>(
          listener: (ctx, state) {
            if (state is LogoutSuccess) {
              // TODO: navigate to login — e.g. context.go('/login')
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            }
            if (state is LogoutFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.cancelled,
              ));
            }
          },
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.bgBase,
          body: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileCard(
                          userName: widget.userName,
                          userEmail: widget.userEmail,
                          avatarUrl: widget.userAvatarUrl,
                        ),
                        const SizedBox(height: 28),

                        // ── Preferences ──────────────────────────────────
                        _SectionHeader('Preferences'),
                        _SettingsCard(items: [
                          _TileData(
                            icon: Icons.notifications_rounded,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.primarySurface,
                            label: 'Notification Settings',
                            subtitle: 'Push, email & reminder preferences',
                            onTap: () => _push(NotificationSettingsScreen(
                                userId: widget.userId)),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Legal ─────────────────────────────────────────
                        _SectionHeader('Legal'),
                        _SettingsCard(items: [
                          _TileData(
                            icon: Icons.shield_rounded,
                            iconColor: AppColors.completed,
                            iconBg: AppColors.completedSurface,
                            label: 'Privacy Policy',
                            subtitle: 'How we handle your data',
                            onTap: () => _push(const PrivacyPolicyScreen()),
                          ),
                          _TileData(
                            icon: Icons.description_rounded,
                            iconColor: AppColors.accent,
                            iconBg: AppColors.primarySurface,
                            label: 'Terms & Conditions',
                            subtitle: 'Usage rules and agreements',
                            onTap: () =>
                                _push(const TermsConditionsScreen()),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Support ───────────────────────────────────────
                        _SectionHeader('Support'),
                        _SettingsCard(items: [
                          _TileData(
                            icon: Icons.headset_mic_rounded,
                            iconColor: AppColors.pending,
                            iconBg: AppColors.pendingSurface,
                            label: 'Help & Support',
                            subtitle: 'FAQs and contact options',
                            onTap: () => _push(const HelpSupportScreen()),
                          ),
                          _TileData(
                            icon: Icons.info_rounded,
                            iconColor: AppColors.confirmed,
                            iconBg: AppColors.confirmedSurface,
                            label: 'About App',
                            subtitle: 'Version, licenses & more',
                            onTap: () => _push(const AboutAppScreen()),
                          ),
                        ]),

                        const SizedBox(height: 32),
                        _LogoutButton(),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'iDoc  •  v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              letterSpacing: 0.4,
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
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 116,
      pinned: true,
      backgroundColor: AppColors.gradientStart,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -24,
              right: -18,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 80,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

// ════════════════════════════════════════════════════════════════════════════
//  Profile Card
// ════════════════════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? avatarUrl;

  const _ProfileCard({
    required this.userName,
    required this.userEmail,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = userName.trim().isNotEmpty
        ? userName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2.5),
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Initials(initials))
                  : _Initials(initials),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  userEmail,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Edit profile pill
                GestureDetector(
                  onTap: () {
                    // TODO: navigate to profile edit
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_rounded,
                            size: 12, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

class _Initials extends StatelessWidget {
  final String text;
  const _Initials(this.text);
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withValues(alpha: 0.18),
        alignment: Alignment.center,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22)),
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  Section header
// ════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  Settings Card + Tile
// ════════════════════════════════════════════════════════════════════════════

class _TileData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _TileData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });
}

class _SettingsCard extends StatelessWidget {
  final List<_TileData> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: List.generate(items.length, (i) => Column(
            children: [
              _SettingsTile(data: items[i]),
              if (i < items.length - 1)
                const Divider(
                    height: 1, indent: 64, endIndent: 16,
                    color: AppColors.divider),
            ],
          )),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final _TileData data;
  const _SettingsTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        )),
                    const SizedBox(height: 2),
                    Text(data.subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              data.trailing ??
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Logout Button
// ════════════════════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogoutBloc, LogoutState>(
      builder: (ctx, state) {
        final busy = state is LogoutLoading;
        return GestureDetector(
          onTap: busy ? null : () => _confirmLogout(ctx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.cancelled.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.cancelled.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.cancelled),
                  )
                else
                  const Icon(Icons.logout_rounded,
                      color: AppColors.cancelled, size: 20),
                const SizedBox(width: 10),
                Text(
                  busy ? 'Logging out…' : 'Log Out',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cancelled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cancelled.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.cancelled, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Log Out',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Fire into the dedicated LogoutBloc — not SettingsBloc
              context.read<LogoutBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cancelled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Log Out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}