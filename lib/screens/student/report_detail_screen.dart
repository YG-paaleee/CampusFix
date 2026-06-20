import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/status_styles.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              _HeaderCard(report: report),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Status Progress',
                icon: Icons.timeline_rounded,
                child: _StatusProgress(currentStatus: report.status),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Details',
                icon: Icons.assignment_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      label: 'Report ID',
                      value: report.reportId,
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      label: 'Date submitted',
                      value: formatDate(report.submittedAt),
                    ),
                    const _RowDivider(),
                    _DetailRow(
                      label: 'Category',
                      value: report.category.label,
                    ),
                    const _RowDivider(),
                    _DetailRow(label: 'Location', value: report.location),
                    const _RowDivider(),
                    _DetailRow(
                      label: 'Staff note',
                      value: report.assignedStaffName == null
                          ? 'No staff update yet.'
                          : 'Assigned to ${report.assignedStaffName}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Description',
                icon: Icons.notes_rounded,
                child: Text(
                  report.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.ink,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(status: report.status),
                UrgencyChip(urgency: report.urgency),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({required this.currentStatus});

  final ReportStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    const statuses = ReportStatus.values;
    final currentIndex = statuses.indexOf(currentStatus);

    return Column(
      children: [
        for (var index = 0; index < statuses.length; index++)
          _ProgressStep(
            status: statuses[index],
            isActive: currentIndex >= index && currentIndex != -1,
            isCurrent: currentIndex == index,
            isFirst: index == 0,
            isLast: index == statuses.length - 1,
          ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.status,
    required this.isActive,
    required this.isCurrent,
    required this.isFirst,
    required this.isLast,
  });

  final ReportStatus status;
  final bool isActive;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final activeColor = statusColor(status);
    final color = isActive ? activeColor : AppColors.inkSoft;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isFirst
                      ? Colors.transparent
                      : (isActive
                            ? activeColor.withValues(alpha: 0.35)
                            : AppColors.border),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.12)
                      : AppColors.canvas,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? activeColor : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isActive
                      ? (isCurrent
                            ? statusIcon(status)
                            : Icons.check_rounded)
                      : Icons.circle_outlined,
                  size: 14,
                  color: color,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast
                      ? Colors.transparent
                      : (isActive
                            ? activeColor.withValues(alpha: 0.35)
                            : AppColors.border),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      color: isActive ? AppColors.ink : AppColors.inkSoft,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Current status',
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
