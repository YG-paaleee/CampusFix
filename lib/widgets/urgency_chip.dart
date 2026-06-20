import 'package:flutter/material.dart';

import '../models/report_options.dart';
import '../utils/status_styles.dart';

/// A soft, rounded pill that shows a report's urgency with a matching icon.
class UrgencyChip extends StatelessWidget {
  const UrgencyChip({super.key, required this.urgency});

  final ReportUrgency urgency;

  @override
  Widget build(BuildContext context) {
    final color = urgencyColor(urgency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: urgencyBackground(urgency),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(urgencyIcon(urgency), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '${urgency.label} urgency',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
