import 'package:flutter/material.dart';
import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../models/staff_account.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/status_styles.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

class AdminReportManagementScreen extends StatefulWidget {
  const AdminReportManagementScreen({
    super.key,
    required this.report,
    required this.staff,
    required this.onStatusChanged,
    required this.onStaffAssigned,
    required this.onUnassign,
    required this.onNoteAdded,
  });

  final MaintenanceReport report;
  final List<StaffAccount> staff;
  final ValueChanged<ReportStatus> onStatusChanged;
  final void Function(String staffId, String staffName) onStaffAssigned;
  final VoidCallback onUnassign;
  final ValueChanged<String> onNoteAdded;

  @override
  State<AdminReportManagementScreen> createState() => _AdminReportManagementScreenState();
}

class _AdminReportManagementScreenState extends State<AdminReportManagementScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildDetailsCard(),
                const SizedBox(height: 20),
                _buildManagementSection(),
                const SizedBox(height: 20),
                _buildNotesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.report.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatusChip(status: widget.report.status),
                UrgencyChip(urgency: widget.report.urgency),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Details'),
            const SizedBox(height: 20),
            _DetailRow(label: 'Report ID', value: widget.report.reportId),
            _DetailRow(label: 'Submitted By', value: 'Student ${widget.report.studentId}'),
            _DetailRow(label: 'Date', value: formatDate(widget.report.submittedAt)),
            _DetailRow(label: 'Location', value: widget.report.location),
            _DetailRow(label: 'Category', value: widget.report.category.label),
            _DetailRow(
              label: 'Urgency',
              value: widget.report.urgency.label,
              valueColor: urgencyColor(widget.report.urgency),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.report.description,
              style: const TextStyle(fontSize: 16, color: AppColors.ink, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Management'),
            const SizedBox(height: 20),
            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReportStatus>(
              value: widget.report.status,
              items: ReportStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onStatusChanged(value);
                  _showSnack('Status updated to ${value.label}.');
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Assign To',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: widget.report.assignedStaffId,
              hint: const Text('Unassigned'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Unassigned'),
                ),
                ...widget.staff.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s.staffId,
                    enabled: s.isActive,
                    child: Text(
                      s.isActive
                          ? '${s.fullName} — ${s.specialty}'
                          : '${s.fullName} — ${s.specialty} (inactive)',
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  widget.onUnassign();
                  _showSnack('Report unassigned.');
                  return;
                }
                final staff =
                    widget.staff.firstWhere((s) => s.staffId == value);
                widget.onStaffAssigned(staff.staffId, staff.fullName);
                _showSnack('Assigned to ${staff.fullName}.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Notes & Updates'),
            const SizedBox(height: 20),
            if (widget.report.notes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'No notes added yet.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.report.notes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.brandSoft,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.report.notes[index],
                            style: const TextStyle(
                              color: AppColors.ink,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Add a status update note...',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () {
                    final text = _noteController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onNoteAdded(text);
                      _noteController.clear();
                      _showSnack('Note added.');
                    }
                  },
                  child: const Text('Add Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueColor != null ? FontWeight.w700 : FontWeight.normal,
                color: valueColor ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
