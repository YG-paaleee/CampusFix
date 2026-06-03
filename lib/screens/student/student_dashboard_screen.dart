import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import 'my_reports_screen.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('CampusFix Student')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track campus repairs and submit maintenance requests.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFFFE8C8),
                  ),
                ),
              ],
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
          Text('Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final report = await Navigator.push<MaintenanceReport>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubmitReportScreen(),
                ),
              );
              if (report == null) {
                return;
              }
              onReportCreated(report);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted.')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Submit Report'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyReportsScreen(reports: reports),
                ),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('My Reports'),
          ),
        ],
      ),
    );
  }

  int _countReportsByStatus(String status) {
    return reports.where((report) => report.status == status).length;
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
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(label),
              ],
            ),
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}
