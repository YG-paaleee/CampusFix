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
                    leading: const Icon(Icons.build),
                    title: Text(report.title),
                    subtitle: Text('${report.category} - ${report.location}'),
                    trailing: Chip(label: Text(report.status)),
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
          Chip(label: Text(report.status)),
          const SizedBox(height: 24),
          _DetailRow(label: 'Category', value: report.category),
          _DetailRow(label: 'Location', value: report.location),
          _DetailRow(label: 'Urgency', value: report.urgency),
          _DetailRow(label: 'Description', value: report.description),
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
