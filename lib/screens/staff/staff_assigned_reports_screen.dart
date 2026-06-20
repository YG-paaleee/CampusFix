import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/status_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

typedef ReportStatusUpdater =
    void Function(String reportId, ReportStatus newStatus);

class StaffAssignedReportsScreen extends StatelessWidget {
  const StaffAssignedReportsScreen({
    super.key,
    required this.reports,
    required this.onUpdateStatus,
  });

  final List<MaintenanceReport> reports;
  final ReportStatusUpdater onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: reports.isEmpty
          ? const EmptyState(
              icon: Icons.assignment_turned_in_outlined,
              title: 'You are all caught up',
              message: 'No reports are assigned to you yet.',
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _StaffReportCard(
                      report: report,
                      onUpdateStatus: onUpdateStatus,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _StaffReportCard extends StatelessWidget {
  const _StaffReportCard({required this.report, required this.onUpdateStatus});

  final MaintenanceReport report;
  final ReportStatusUpdater onUpdateStatus;

  void _update(BuildContext context, ReportStatus newStatus) {
    onUpdateStatus(report.reportId, newStatus);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${report.title}" marked as ${newStatus.label}.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(status: report.status),
                UrgencyChip(urgency: report.urgency),
              ],
            ),
            const SizedBox(height: 12),
            _MetaRow(icon: Icons.place_outlined, text: report.location),
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.category_outlined,
              text: report.category.label,
            ),
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.event_outlined,
              text: 'Submitted ${formatDate(report.submittedAt)}',
            ),
            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.description,
                  style: const TextStyle(
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const Divider(height: 28),
            _StatusActions(
              status: report.status,
              onUpdate: (newStatus) => _update(context, newStatus),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly, contextual buttons that let staff move a repair forward.
class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.status, required this.onUpdate});

  final ReportStatus status;
  final ValueChanged<ReportStatus> onUpdate;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ReportStatus.submitted:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onUpdate(ReportStatus.inProgress),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start repair'),
              ),
            ),
          ],
        );
      case ReportStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onUpdate(ReportStatus.resolved),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Mark as resolved'),
              ),
            ),
          ],
        );
      case ReportStatus.resolved:
        return Row(
          children: [
            Icon(
              Icons.verified_rounded,
              size: 18,
              color: statusColor(ReportStatus.resolved),
            ),
            const SizedBox(width: 8),
            Text(
              'This repair is complete.',
              style: TextStyle(
                color: statusColor(ReportStatus.resolved),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => onUpdate(ReportStatus.inProgress),
              child: const Text('Reopen'),
            ),
          ],
        );
      case ReportStatus.rejected:
        return Row(
          children: [
            Icon(
              Icons.block_rounded,
              size: 18,
              color: statusColor(ReportStatus.rejected),
            ),
            const SizedBox(width: 8),
            Text(
              'This report was rejected by an admin.',
              style: TextStyle(
                color: statusColor(ReportStatus.rejected),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.inkSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
