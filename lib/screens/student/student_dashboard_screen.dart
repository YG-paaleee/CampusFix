import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/header_banner.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
    required this.reports,
    required this.onLogout,
  });

  final List<MaintenanceReport> reports;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final submittedCount = _countReportsByStatus(ReportStatus.submitted);
    final inProgressCount = _countReportsByStatus(ReportStatus.inProgress);
    final resolvedCount = _countReportsByStatus(ReportStatus.resolved);
    final highUrgencyCount = reports
        .where(
          (report) =>
              report.urgency == ReportUrgency.high &&
              report.status != ReportStatus.resolved,
        )
        .length;
    final recentReports = reports.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BrandMark(),
            const SizedBox(width: 10),
            const Text('CampusFix Student'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              HeaderBanner(
                eyebrow: 'Student Area',
                title: 'Student Dashboard',
                subtitle:
                    'Track campus repairs and submit maintenance requests.',
                note: highUrgencyCount == 0
                    ? 'No open high-urgency reports 🎉'
                    : '$highUrgencyCount open high-urgency report${highUrgencyCount == 1 ? '' : 's'} need attention',
                action: FilledButton.icon(
                  onPressed: () => context.push('/student/reports/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Submit Report'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brand,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  final cardWidth = isNarrow
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 24) / 3;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          label: ReportStatus.submitted.label,
                          value: '$submittedCount',
                          icon: Icons.fiber_new_rounded,
                          color: AppColors.statusSubmitted,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          label: ReportStatus.inProgress.label,
                          value: '$inProgressCount',
                          icon: Icons.autorenew_rounded,
                          color: AppColors.statusInProgress,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          label: ReportStatus.resolved.label,
                          value: '$resolvedCount',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.statusResolved,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Recent Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/student/reports'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('My Reports'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recentReports.isEmpty)
                Card(
                  child: EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No reports yet',
                    message:
                        'Submit your first maintenance request and it will show up here.',
                    action: FilledButton.icon(
                      onPressed: () => context.push('/student/reports/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Submit Report'),
                    ),
                  ),
                )
              else
                ...recentReports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportTile(report: report),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _countReportsByStatus(ReportStatus status) {
    return reports.where((report) => report.status == status).length;
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/student/reports/${report.reportId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.report_problem_outlined,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.reportId} • ${formatDate(report.submittedAt)}',
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${report.category.label} • ${report.location}',
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(status: report.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Text(
        'CF',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
