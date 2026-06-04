import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import 'my_reports_screen.dart';
import 'report_detail_screen.dart';
import 'submit_report_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
    required this.reports,
    required this.onReportCreated,
  });

  final List<MaintenanceReport> reports;
  final ValueChanged<MaintenanceReport> onReportCreated;

  @override
  Widget build(BuildContext context) {
    final submittedCount = _countReportsByStatus('Submitted');
    final inProgressCount = _countReportsByStatus('In Progress');
    final resolvedCount = _countReportsByStatus('Resolved');
    final highUrgencyCount = reports
        .where(
          (report) => report.urgency == 'High' && report.status != 'Resolved',
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
            ),
            const SizedBox(width: 10),
            const Text('CampusFix Student'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
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
              _DashboardHeader(
                highUrgencyCount: highUrgencyCount,
                onSubmitPressed: () => _openSubmitForm(context),
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
                        child: _StatusCard(
                          label: 'Submitted',
                          value: '$submittedCount',
                          icon: Icons.pending_actions,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _StatusCard(
                          label: 'In Progress',
                          value: '$inProgressCount',
                          icon: Icons.engineering,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _StatusCard(
                          label: 'Resolved',
                          value: '$resolvedCount',
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Recent Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openMyReports(context),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('My Reports'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (reports.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('No reports have been submitted yet.'),
                        )
                      else
                        ...reports.take(3).map((report) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFEAF2EE),
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              child: const Icon(
                                Icons.report_problem_outlined,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              report.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${report.reportId} - ${_formatDate(report.submittedAt)}\n${report.category} - ${report.location}',
                            ),
                            isThreeLine: true,
                            trailing: _StatusPill(status: report.status),
                            onTap: () => _openReportDetails(context, report),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSubmitForm(BuildContext context) async {
    final report = await Navigator.push<MaintenanceReport>(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitReportScreen(nextReportId: _nextReportId),
      ),
    );

    if (report == null) {
      return;
    }

    onReportCreated(report);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
  }

  void _openMyReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyReportsScreen(reports: reports),
      ),
    );
  }

  void _openReportDetails(BuildContext context, MaintenanceReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }

  int _countReportsByStatus(String status) {
    return reports.where((report) => report.status == status).length;
  }

  String get _nextReportId {
    final nextNumber = reports.length + 1;
    return 'CF-${nextNumber.toString().padLeft(4, '0')}';
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.highUrgencyCount,
    required this.onSubmitPressed,
  });

  final int highUrgencyCount;
  final VoidCallback onSubmitPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;
            final intro = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STUDENT AREA',
                  style: TextStyle(
                    color: Color(0xFF0D7C66),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Student Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17211C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track campus repairs and submit maintenance requests.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF506158),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  highUrgencyCount == 0
                      ? 'No open high-urgency reports.'
                      : '$highUrgencyCount open high-urgency report${highUrgencyCount == 1 ? '' : 's'} need attention.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0D7C66),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
            final button = FilledButton.icon(
              onPressed: onSubmitPressed,
              icon: const Icon(Icons.add),
              label: const Text('Submit Report'),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  intro,
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, child: button),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: intro),
                const SizedBox(width: 16),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label),
              ],
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Resolved' => const Color(0xFF2F7D32),
      'In Progress' => const Color(0xFF0D7C66),
      _ => const Color(0xFF114B3A),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
