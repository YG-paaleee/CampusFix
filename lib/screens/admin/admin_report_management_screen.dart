import 'package:flutter/material.dart';
import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_chip.dart';

class AdminReportManagementScreen extends StatefulWidget {
  const AdminReportManagementScreen({
    super.key,
    required this.report,
    required this.onStatusChanged,
    required this.onStaffAssigned,
    required this.onNoteAdded,
  });

  final MaintenanceReport report;
  final ValueChanged<ReportStatus> onStatusChanged;
  final void Function(String staffId, String staffName) onStaffAssigned;
  final ValueChanged<String> onNoteAdded;

  @override
  State<AdminReportManagementScreen> createState() => _AdminReportManagementScreenState();
}

class _AdminReportManagementScreenState extends State<AdminReportManagementScreen> {
  final _noteController = TextEditingController();

  final _mockStaffList = const [
    {'id': 's1', 'name': 'John Doe (Electrician)'},
    {'id': 's2', 'name': 'Jane Smith (Plumber)'},
    {'id': 's3', 'name': 'Mike Johnson (General)'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                _buildManagementSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.report.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        StatusChip(status: widget.report.status),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            _DetailRow(label: 'Report ID', value: widget.report.reportId),
            _DetailRow(label: 'Submitted By', value: 'Student ${widget.report.studentId}'),
            _DetailRow(label: 'Date', value: formatDate(widget.report.submittedAt)),
            _DetailRow(label: 'Location', value: widget.report.location),
            _DetailRow(label: 'Category', value: widget.report.category.label),
            _DetailRow(
              label: 'Urgency',
              value: widget.report.urgency.label,
              valueColor: _getUrgencyColor(widget.report.urgency),
            ),
            const SizedBox(height: 16),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(widget.report.description, style: const TextStyle(fontSize: 16)),
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
            const Text('Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            Row(
              children: [
                const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ReportStatus>(
                    value: widget.report.status,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    items: ReportStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onStatusChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Assign To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.report.assignedStaffId,
                    hint: const Text('Unassigned'),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Unassigned')),
                      ..._mockStaffList.map(
                        (s) => DropdownMenuItem(value: s['id'], child: Text(s['name']!)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        final staff = _mockStaffList.firstWhere((s) => s['id'] == value);
                        widget.onStaffAssigned(staff['id']!, staff['name']!);
                      }
                    },
                  ),
                ),
              ],
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
            const Text('Notes & Updates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            if (widget.report.notes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('No notes added yet.', style: TextStyle(color: Colors.black54)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.report.notes.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E7E1)),
                    ),
                    child: Text(widget.report.notes[index]),
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
                    final text = _noteController.text;
                    if (text.isNotEmpty) {
                      widget.onNoteAdded(text);
                      _noteController.clear();
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
