import 'package:flutter/material.dart';

import '../models/report_options.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ReportStatus.resolved => const Color(0xFF2F7D32),
      ReportStatus.rejected => Colors.redAccent,
      ReportStatus.inProgress => Theme.of(context).colorScheme.secondary,
      ReportStatus.submitted => Theme.of(context).colorScheme.primary,
    };

    return Chip(
      label: Text(status.label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
    );
  }
}
