import 'dart:convert';

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
typedef ReportResolver =
    void Function(String reportId, {required String note, String? imageBase64});
typedef ReportNoteAdder = void Function(String reportId, String note);

class StaffAssignedReportsScreen extends StatelessWidget {
  const StaffAssignedReportsScreen({
    super.key,
    required this.reports,
    required this.onUpdateStatus,
    required this.onResolve,
    required this.onAddNote,
  });

  final List<MaintenanceReport> reports;
  final ReportStatusUpdater onUpdateStatus;
  final ReportResolver onResolve;
  final ReportNoteAdder onAddNote;

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
                      onResolve: onResolve,
                      onAddNote: onAddNote,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _StaffReportCard extends StatelessWidget {
  const _StaffReportCard({
    required this.report,
    required this.onUpdateStatus,
    required this.onResolve,
    required this.onAddNote,
  });

  final MaintenanceReport report;
  final ReportStatusUpdater onUpdateStatus;
  final ReportResolver onResolve;
  final ReportNoteAdder onAddNote;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resolve(BuildContext context) async {
    final result = await showDialog<_ResolveResult>(
      context: context,
      builder: (_) => _ResolveDialog(reportTitle: report.title),
    );
    if (result == null) return;
    onResolve(report.reportId, note: result.note);
    if (context.mounted) _snack(context, 'Repair marked as resolved.');
  }

  Future<void> _putOnHold(BuildContext context) async {
    final reason = await _promptText(
      context,
      title: 'Put on hold',
      hint: 'Reason (e.g. waiting for parts)',
      confirmLabel: 'Put on hold',
    );
    if (reason == null || reason.isEmpty) return;
    onAddNote(report.reportId, 'Put on hold — $reason');
    onUpdateStatus(report.reportId, ReportStatus.onHold);
    if (context.mounted) _snack(context, 'Repair put on hold.');
  }

  Future<void> _addUpdate(BuildContext context) async {
    final text = await _promptText(
      context,
      title: 'Add a progress update',
      hint: 'What did you do?',
      confirmLabel: 'Post update',
    );
    if (text == null || text.isEmpty) return;
    onAddNote(report.reportId, text);
    if (context.mounted) _snack(context, 'Update posted.');
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = report.status == ReportStatus.resolved;

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
                  style: const TextStyle(color: AppColors.ink, height: 1.4),
                ),
              ),
            ],
            if (report.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _MiniLabel('Updates'),
              const SizedBox(height: 8),
              ...report.notes.map((note) => _NoteBubble(text: note)),
            ],
            if (isResolved && report.resolutionNote != null) ...[
              const SizedBox(height: 16),
              _ResolutionEvidence(
                note: report.resolutionNote!,
                imageBase64: report.resolutionImage,
              ),
            ],
            const Divider(height: 28),
            _StatusActions(
              status: report.status,
              onStart: () {
                onUpdateStatus(report.reportId, ReportStatus.inProgress);
                _snack(context, 'Repair started.');
              },
              onResolve: () => _resolve(context),
              onHold: () => _putOnHold(context),
              onResume: () {
                onUpdateStatus(report.reportId, ReportStatus.inProgress);
                _snack(context, 'Repair resumed.');
              },
              onAddUpdate: () => _addUpdate(context),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Status-dependent action buttons for a staff member working a repair.
class _StatusActions extends StatelessWidget {
  const _StatusActions({
    required this.status,
    required this.onStart,
    required this.onResolve,
    required this.onHold,
    required this.onResume,
    required this.onAddUpdate,
  });

  final ReportStatus status;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onHold;
  final VoidCallback onResume;
  final VoidCallback onAddUpdate;

  @override
  Widget build(BuildContext context) {
    final updateButton = TextButton.icon(
      onPressed: onAddUpdate,
      icon: const Icon(Icons.add_comment_outlined, size: 18),
      label: const Text('Add update'),
    );

    switch (status) {
      case ReportStatus.submitted:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start repair'),
              ),
            ),
            const SizedBox(width: 8),
            updateButton,
          ],
        );
      case ReportStatus.inProgress:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Mark resolved'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHold,
                    icon: const Icon(Icons.pause_rounded),
                    label: const Text('On hold'),
                  ),
                ),
              ],
            ),
            Align(alignment: Alignment.centerLeft, child: updateButton),
          ],
        );
      case ReportStatus.onHold:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume repair'),
              ),
            ),
            const SizedBox(width: 8),
            updateButton,
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
            TextButton(onPressed: onResume, child: const Text('Reopen')),
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
            Expanded(
              child: Text(
                'This report was rejected by an admin.',
                style: TextStyle(
                  color: statusColor(ReportStatus.rejected),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _ResolveResult {
  const _ResolveResult({required this.note});

  final String note;
}

class _ResolveDialog extends StatefulWidget {
  const _ResolveDialog({required this.reportTitle});

  final String reportTitle;

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  final _noteController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      setState(() => _error = 'Please describe how the issue was resolved.');
      return;
    }
    Navigator.of(context).pop(_ResolveResult(note: note));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Complete repair'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add a completion note for "${widget.reportTitle}".',
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Resolution note',
                  hintText: 'What was done to fix the issue?',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.statusRejected,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Mark resolved'),
        ),
      ],
    );
  }
}

class _ResolutionEvidence extends StatelessWidget {
  const _ResolutionEvidence({required this.note, this.imageBase64});

  final String note;
  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.statusResolvedBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 18,
                color: statusColor(ReportStatus.resolved),
              ),
              const SizedBox(width: 8),
              Text(
                'Completion evidence',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: statusColor(ReportStatus.resolved),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(note, style: const TextStyle(color: AppColors.ink, height: 1.4)),
          if (imageBase64 != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(imageBase64!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteBubble extends StatelessWidget {
  const _NoteBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.ink, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.inkSoft,
      ),
    );
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
