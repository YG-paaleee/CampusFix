import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/header_banner.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({
    super.key,
    required this.assignedReports,
    required this.pendingTasks,
    required this.urgentTasks,
    required this.onLogout,
    this.staffName,
  });

  final List<MaintenanceReport> assignedReports;
  final int pendingTasks;
  final int urgentTasks;
  final VoidCallback onLogout;
  final String? staffName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                HeaderBanner(
                  eyebrow: 'Maintenance Staff',
                  title: 'Welcome, Maintenance Team',
                  subtitle: staffName == null
                      ? 'Here is your current task summary.'
                      : 'Signed in as $staffName - here is your current task summary.',
                  icon: Icons.handyman_outlined,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 520;
                    const spacing = 16.0;

                    final pendingCard = StatCard(
                      label: 'My Pending Tasks',
                      value: pendingTasks.toString(),
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.statusInProgress,
                    );
                    final urgentCard = StatCard(
                      label: 'Urgent Repairs',
                      value: urgentTasks.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.urgencyHigh,
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          pendingCard,
                          const SizedBox(height: spacing),
                          urgentCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: pendingCard),
                        const SizedBox(width: spacing),
                        Expanded(child: urgentCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _AssignedWorkSection(reports: assignedReports),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignedWorkSection extends StatelessWidget {
  const _AssignedWorkSection({required this.reports});

  final List<MaintenanceReport> reports;

  @override
  Widget build(BuildContext context) {
    final activeReports =
        reports
            .where(
              (report) =>
                  report.status != ReportStatus.resolved &&
                  report.status != ReportStatus.rejected,
            )
            .toList()
          ..sort((a, b) {
            final urgencyCompare = b.urgency.rank.compareTo(a.urgency.rank);
            if (urgencyCompare != 0) return urgencyCompare;
            return b.submittedAt.compareTo(a.submittedAt);
          });
    final visibleReports = activeReports.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Assigned repairs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/staff/assignments'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open full list'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (visibleReports.isEmpty)
              const Text(
                'No active assigned repairs right now.',
                style: TextStyle(color: AppColors.inkSoft),
              )
            else
              ...visibleReports.map((report) {
                return _AssignedRepairPreview(report: report);
              }),
          ],
        ),
      ),
    );
  }
}

class _AssignedRepairPreview extends StatelessWidget {
  const _AssignedRepairPreview({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.title,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${report.location} - submitted ${formatDate(report.submittedAt)}',
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(status: report.status),
              UrgencyChip(urgency: report.urgency),
            ],
          ),
        ],
      ),
    );
  }
}
