import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_state.dart';

/// ---------------------------------------------------------------------------
/// Home Screen — main dashboard after successful login.
///
/// Currently a placeholder showing student info and upcoming feature cards.
/// Each feature card is a wireframe for a screen you'll build next.
/// ---------------------------------------------------------------------------
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final student = authState is AuthAuthenticated ? authState.student : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          _buildSliverAppBar(context, ref, student?.name ?? 'Student'),

          // ── Body ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingM,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Student Info Card ─────────────────────────────────
                if (student != null) _StudentInfoCard(student: student),
                const SizedBox(height: AppConstants.paddingL),

                // ── Quick Actions ─────────────────────────────────────
                Text('Quick Actions', style: AppTextStyles.headingMedium),
                const SizedBox(height: AppConstants.paddingM),
                _buildQuickActions(context),
                const SizedBox(height: AppConstants.paddingL),

                // ── Upcoming Feature Sections ─────────────────────────
                Text('Features Coming Soon', style: AppTextStyles.headingMedium),
                const SizedBox(height: AppConstants.paddingM),
                _buildFeatureGrid(context),
                const SizedBox(height: AppConstants.paddingXXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, String studentName) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // FUTURE: context.push(RouteConstants.notifications)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () => _showLogoutDialog(context, ref),
        ),
        const SizedBox(width: AppConstants.paddingS),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingL,
                AppConstants.paddingL,
                AppConstants.paddingL,
                AppConstants.paddingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentName,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.appBarTitle,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Book a Field',
            prefixIcon: Icons.add_circle_outline_rounded,
            onPressed: () {
              // FUTURE: context.push(RouteConstants.fieldList)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Field booking coming soon!')),
              );
            },
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: AppButton(
            label: 'My Bookings',
            prefixIcon: Icons.history_rounded,
            isOutlined: true,
            onPressed: () {
              // FUTURE: context.push(RouteConstants.reservationHistory)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking history coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Feature Grid ─────────────────────────────────────────────────────────

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.sports_soccer_rounded,
        label: 'Field List',
        description: 'Browse all available football fields',
        color: AppColors.primary,
        route: 'fields', // RouteConstants.fieldList
      ),
      _FeatureItem(
        icon: Icons.schedule_rounded,
        label: 'Time Slots',
        description: 'View and select available time slots',
        color: AppColors.info,
        route: 'slots',
      ),
      _FeatureItem(
        icon: Icons.pending_actions_rounded,
        label: 'Reservations',
        description: 'Track your booking requests',
        color: AppColors.warning,
        route: 'reservations',
      ),
      _FeatureItem(
        icon: Icons.admin_panel_settings_rounded,
        label: 'Admin Panel',
        description: 'Approve or reject bookings',
        color: AppColors.secondary,
        route: 'admin',
      ),
      _FeatureItem(
        icon: Icons.notifications_rounded,
        label: 'Notifications',
        description: 'Real-time booking updates',
        color: AppColors.error,
        route: 'notifications',
      ),
      _FeatureItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        description: 'Manage your student profile',
        color: AppColors.primaryLight,
        route: 'profile',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.paddingM,
        mainAxisSpacing: AppConstants.paddingM,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => _FeatureCard(item: features[index]),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _StudentInfoCard extends StatelessWidget {
  final dynamic student; // Student entity

  const _StudentInfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, Colors.white],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty
                    ? student.name[0].toUpperCase()
                    : '?',
                style: AppTextStyles.headingLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(
                  'ID: ${student.studentId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(student.department),
                    const SizedBox(width: AppConstants.paddingXS),
                    _InfoChip(student.year),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final String route;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.route,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.label} — coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}