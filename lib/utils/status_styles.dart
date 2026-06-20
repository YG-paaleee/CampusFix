import 'package:flutter/material.dart';

import '../models/report_options.dart';
import '../theme/app_colors.dart';

/// Shared mapping of report status / urgency to colours and icons, so chips,
/// cards, and badges across every screen stay perfectly consistent.

Color statusColor(ReportStatus status) => switch (status) {
  ReportStatus.submitted => AppColors.statusSubmitted,
  ReportStatus.inProgress => AppColors.statusInProgress,
  ReportStatus.onHold => AppColors.statusOnHold,
  ReportStatus.resolved => AppColors.statusResolved,
  ReportStatus.rejected => AppColors.statusRejected,
};

Color statusBackground(ReportStatus status) => switch (status) {
  ReportStatus.submitted => AppColors.statusSubmittedBg,
  ReportStatus.inProgress => AppColors.statusInProgressBg,
  ReportStatus.onHold => AppColors.statusOnHoldBg,
  ReportStatus.resolved => AppColors.statusResolvedBg,
  ReportStatus.rejected => AppColors.statusRejectedBg,
};

IconData statusIcon(ReportStatus status) => switch (status) {
  ReportStatus.submitted => Icons.fiber_new_rounded,
  ReportStatus.inProgress => Icons.autorenew_rounded,
  ReportStatus.onHold => Icons.pause_circle_filled_rounded,
  ReportStatus.resolved => Icons.check_circle_rounded,
  ReportStatus.rejected => Icons.cancel_rounded,
};

Color urgencyColor(ReportUrgency urgency) => switch (urgency) {
  ReportUrgency.high => AppColors.urgencyHigh,
  ReportUrgency.medium => AppColors.urgencyMedium,
  ReportUrgency.low => AppColors.urgencyLow,
};

Color urgencyBackground(ReportUrgency urgency) => switch (urgency) {
  ReportUrgency.high => AppColors.urgencyHighBg,
  ReportUrgency.medium => AppColors.urgencyMediumBg,
  ReportUrgency.low => AppColors.urgencyLowBg,
};

IconData urgencyIcon(ReportUrgency urgency) => switch (urgency) {
  ReportUrgency.high => Icons.priority_high_rounded,
  ReportUrgency.medium => Icons.remove_rounded,
  ReportUrgency.low => Icons.south_rounded,
};
