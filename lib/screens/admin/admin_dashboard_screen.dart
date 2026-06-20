import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/header_banner.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.onLogout,
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.urgentReports,
  });

  final VoidCallback onLogout;
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final int urgentReports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const HeaderBanner(
                  eyebrow: 'Admin Area',
                  title: 'Welcome back, Admin',
                  subtitle:
                      'Here is the current status of all maintenance reports across campus.',
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width > 880
                        ? 4
                        : (width > 560 ? 2 : 1);
                    final spacing = 16.0;
                    final cardWidth =
                        (width - spacing * (columns - 1)) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            label: 'Total Reports',
                            value: totalReports.toString(),
                            icon: Icons.assignment_rounded,
                            color: AppColors.brand,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            label: 'Pending',
                            value: pendingReports.toString(),
                            icon: Icons.pending_actions_rounded,
                            color: AppColors.statusSubmitted,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            label: 'Resolved',
                            value: resolvedReports.toString(),
                            icon: Icons.check_circle_rounded,
                            color: AppColors.statusResolved,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            label: 'Urgent',
                            value: urgentReports.toString(),
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.urgencyHigh,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        context.go('/admin/reports');
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View All Reports'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.go('/admin/staff');
                      },
                      icon: const Icon(Icons.people_alt),
                      label: const Text('Manage Staff'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
