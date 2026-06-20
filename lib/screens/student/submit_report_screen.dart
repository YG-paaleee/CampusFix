import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';

typedef ReportCreatedHandler = Future<void> Function(MaintenanceReport report);
typedef ReportIdGenerator = String Function();

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    super.key,
    required this.studentUid,
    required this.studentId,
    required this.createReportId,
    required this.onReportCreated,
  });

  final String studentUid;
  final String studentId;
  final ReportIdGenerator createReportId;
  final ReportCreatedHandler onReportCreated;

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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final report = MaintenanceReport(
      studentUid: widget.studentUid,
      studentId: widget.studentId,
      reportId: widget.createReportId(),
      submittedAt: DateTime.now(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      category: _category,
      urgency: _urgency,
      status: ReportStatus.submitted,
      description: _descriptionController.text.trim(),
    );

    await widget.onReportCreated(report);

    if (!mounted) {
      return;
    }

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide clear details so the report can be reviewed and assigned quickly.',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 15),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Issue title',
                            hintText: 'e.g. Broken projector in Room 301',
                            prefixIcon: Icon(Icons.title_rounded),
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
                            prefixIcon: Icon(Icons.category_outlined),
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
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Location or room',
                            hintText: 'e.g. Building A, Room 301',
                            prefixIcon: Icon(Icons.place_outlined),
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
                            prefixIcon: Icon(Icons.flag_outlined),
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
                            hintText:
                                'Describe the problem and anything staff should know.',
                            alignLabelWithHint: true,
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
                            icon: const Icon(Icons.send_rounded),
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
