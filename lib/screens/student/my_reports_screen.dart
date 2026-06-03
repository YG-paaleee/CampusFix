import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: reports.isEmpty
          ? const Center(child: Text('No reports yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.build, size: 20),
                    ),
                    title: Text(report.title),
                    subtitle: Text(
                      '${report.category} - ${report.location}\nUrgency: ${report.urgency}',
                    ),
                    trailing: _StatusChip(status: report.status),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              _ReportDetailScreen(report: report),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _ReportDetailScreen extends StatelessWidget {
  const _ReportDetailScreen({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(report.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          _StatusChip(status: report.status),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Category', value: report.category),
                  _DetailRow(label: 'Location', value: report.location),
                  _DetailRow(label: 'Urgency', value: report.urgency),
                  _DetailRow(label: 'Description', value: report.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Resolved' => const Color(0xFF2F7D32),
      'In Progress' => Theme.of(context).colorScheme.secondary,
      _ => Theme.of(context).colorScheme.primary,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
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
