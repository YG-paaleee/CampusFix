import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/status_styles.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/header_banner.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.onLogout,
    required this.reports,
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.urgentReports,
  });

  final VoidCallback onLogout;
  final List<MaintenanceReport> reports;
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
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Log out?',
                message: 'You will be returned to the login screen.',
                confirmLabel: 'Log out',
              );
              if (ok) onLogout();
            },
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
                _AnalyticsSection(reports: reports),
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
                        context.push('/admin/reports');
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
                        context.push('/admin/staff');
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

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.reports});

  final List<MaintenanceReport> reports;

  @override
  Widget build(BuildContext context) {
    final statusEntries = [
      for (final s in ReportStatus.values)
        _BreakdownEntry(
          label: s.label,
          count: reports.where((r) => r.status == s).length,
          color: statusColor(s),
        ),
    ];
    final categoryEntries = [
      for (final c in ReportCategory.values)
        _BreakdownEntry(
          label: c.label,
          count: reports.where((r) => r.category == c).length,
          color: AppColors.accent,
        ),
    ]..removeWhere((e) => e.count == 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final statusCard = _BreakdownCard(
          title: 'Reports by status',
          icon: Icons.donut_small_rounded,
          entries: statusEntries,
        );
        final categoryCard = _BreakdownCard(
          title: 'Reports by category',
          icon: Icons.category_rounded,
          entries: categoryEntries,
        );

        if (constraints.maxWidth > 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: statusCard),
              const SizedBox(width: 16),
              Expanded(child: categoryCard),
            ],
          );
        }
        return Column(
          children: [
            statusCard,
            const SizedBox(height: 16),
            categoryCard,
          ],
        );
      },
    );
  }
}

class _BreakdownEntry {
  const _BreakdownEntry({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<_BreakdownEntry> entries;

  @override
  Widget build(BuildContext context) {
    final maxCount = entries.fold<int>(
      1,
      (m, e) => e.count > m ? e.count : m,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.brand),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (entries.isEmpty)
              const Text(
                'No data yet.',
                style: TextStyle(color: AppColors.inkSoft),
              )
            else
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.label,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.count}',
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 8,
                          color: AppColors.canvas,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: entry.count / maxCount,
                            child: Container(color: entry.color),
                          ),
                        ),
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
