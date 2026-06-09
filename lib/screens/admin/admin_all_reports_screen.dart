import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_chip.dart';

class AdminAllReportsScreen extends StatefulWidget {
  const AdminAllReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  State<AdminAllReportsScreen> createState() => _AdminAllReportsScreenState();
}

class _AdminAllReportsScreenState extends State<AdminAllReportsScreen> {
  ReportStatus? _selectedStatus;
  ReportUrgency? _selectedUrgency;

  @override
  Widget build(BuildContext context) {
    var filteredReports = widget.reports;

    if (_selectedStatus != null) {
      filteredReports = filteredReports.where((r) => r.status == _selectedStatus).toList();
    }

    if (_selectedUrgency != null) {
      filteredReports = filteredReports.where((r) => r.urgency == _selectedUrgency).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1, color: Color(0xFFE2E7E1)),
          Expanded(
            child: filteredReports.isEmpty
                ? const Center(child: Text('No reports found matching the filters.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _ReportCard(report: report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            DropdownButton<ReportStatus?>(
              value: _selectedStatus,
              hint: const Text('All'),
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ReportStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(width: 24),
            const Text('Urgency:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            DropdownButton<ReportUrgency?>(
              value: _selectedUrgency,
              hint: const Text('All'),
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...ReportUrgency.values.map(
                  (urgency) => DropdownMenuItem(
                    value: urgency,
                    child: Text(urgency.label),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/admin/reports/${report.reportId}');
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
