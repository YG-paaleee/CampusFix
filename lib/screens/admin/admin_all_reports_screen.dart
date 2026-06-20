import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

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

    final hasFilters = _selectedStatus != null || _selectedUrgency != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilters(),
                Expanded(
                  child: filteredReports.isEmpty
                      ? EmptyState(
                          icon: hasFilters
                              ? Icons.filter_alt_off_rounded
                              : Icons.inbox_rounded,
                          title: hasFilters
                              ? 'No matching reports'
                              : 'No reports yet',
                          message: hasFilters
                              ? 'Try clearing the status or urgency filters to see more results.'
                              : 'New maintenance reports will appear here once students submit them.',
                          action: hasFilters
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = null;
                                      _selectedUrgency = null;
                                    });
                                  },
                                  icon: const Icon(Icons.clear_all_rounded),
                                  label: const Text('Clear filters'),
                                )
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return _ReportCard(report: report);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 12),
              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<ReportStatus?>(
                value: _selectedStatus,
                hint: const Text('All'),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(14),
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
              const Text(
                'Urgency',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<ReportUrgency?>(
                value: _selectedUrgency,
                hint: const Text('All'),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(14),
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
          context.push('/admin/reports/${report.reportId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.accent,
                      size: 22,
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.reportId} • ${formatDate(report.submittedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${report.category.label} • ${report.location}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.inkSoft,
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
        ),
      ),
    );
  }
}
