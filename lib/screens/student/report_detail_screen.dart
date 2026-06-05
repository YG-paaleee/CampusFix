import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_chip.dart';

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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                report.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(status: report.status),
                  Text(
                    '${report.reportId} - Submitted ${formatDate(report.submittedAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF506158),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      _StatusProgress(currentStatus: report.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Category',
                        value: report.category.label,
                      ),
                      _DetailRow(label: 'Location', value: report.location),
                      _DetailRow(label: 'Urgency', value: report.urgency.label),
                      _DetailRow(
                        label: 'Description',
                        value: report.description,
                      ),
                      const _DetailRow(
                        label: 'Staff Note',
                        value: 'No staff update yet.',
                      ),
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
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({required this.currentStatus});

  final ReportStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    const statuses = ReportStatus.values;
    final currentIndex = statuses.indexOf(currentStatus);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: statuses.map((status) {
        final index = statuses.indexOf(status);
        final isActive = currentIndex >= index && currentIndex != -1;

        return _ProgressStep(status: status, isActive: isActive);
      }).toList(),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.status, required this.isActive});

  final ReportStatus status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Theme.of(context).colorScheme.secondary
        : const Color(0xFF8B9991);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
