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
      appBar: AppBar(title: const Text('CampusFix')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Student Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your campus maintenance requests.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  label: 'Submitted',
                  value: '$submittedCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  label: 'In Progress',
                  value: '$inProgressCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(label: 'Resolved', value: '$resolvedCount'),
              ),
            ],
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
  const _StatusCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
