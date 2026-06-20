import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_chip.dart';

class StaffAssignedReportsScreen extends StatelessWidget {
  const StaffAssignedReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
      ),
      body: reports.isEmpty
          ? const Center(child: Text('You have no assigned reports.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _StaffReportCard(report: report);
              },
            ),
    );
  }
}

class _StaffReportCard extends StatelessWidget {
  const _StaffReportCard({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Future: Route to Staff Report Details screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: report.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${report.category.label} • Location: ${report.location}',
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: _getUrgencyColor(report.urgency),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.urgency.label} Urgency',
                    style: TextStyle(
                      color: _getUrgencyColor(report.urgency),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Submitted: ${formatDate(report.submittedAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2E7E1)),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(ReportUrgency urgency) {
    switch (urgency) {
      case ReportUrgency.high:
        return Colors.redAccent;
      case ReportUrgency.medium:
        return Colors.orange;
      case ReportUrgency.low:
        return Colors.green;
    }
  }
}
