import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    super.key,
    required this.studentId,
    required this.nextReportId,
    required this.onReportCreated,
  });

  final String studentId;
  final String nextReportId;
  final ValueChanged<MaintenanceReport> onReportCreated;

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  ReportCategory _category = ReportCategory.classroom;
  ReportUrgency _urgency = ReportUrgency.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final report = MaintenanceReport(
      studentId: widget.studentId,
      reportId: widget.nextReportId,
      submittedAt: DateTime.now(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      category: _category,
      urgency: _urgency,
      status: ReportStatus.submitted,
      description: _descriptionController.text.trim(),
    );

    widget.onReportCreated(report);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
    context.go('/student');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Report')),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'File a Maintenance Report',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17211C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Provide clear details so the report can be reviewed and assigned.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Issue title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter an issue title.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ReportCategory>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: ReportCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _category = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location or room',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter the issue location.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ReportUrgency>(
                          initialValue: _urgency,
                          decoration: const InputDecoration(
                            labelText: 'Urgency',
                            border: OutlineInputBorder(),
                          ),
                          items: ReportUrgency.values.map((urgency) {
                            return DropdownMenuItem(
                              value: urgency,
                              child: Text(urgency.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _urgency = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a short description.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _submitReport,
                            icon: const Icon(Icons.send),
                            label: const Text('Submit'),
                          ),
                        ),
                      ],
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
