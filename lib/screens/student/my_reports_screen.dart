import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _SampleReport(
        title: 'Broken classroom chair',
        location: 'Room 204',
        category: 'Classroom',
        status: 'Submitted',
      ),
      _SampleReport(
        title: 'Projector not working',
        location: 'IT Lab 1',
        category: 'IT Equipment',
        status: 'In Progress',
      ),
      _SampleReport(
        title: 'Leaking faucet',
        location: 'Restroom A',
        category: 'Plumbing',
        status: 'Resolved',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: ListView.separated(
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
            ),
          );
        },
      ),
    );
  }
}

class _SampleReport {
  const _SampleReport({
    required this.title,
    required this.location,
    required this.category,
    required this.status,
  });

  final String title;
  final String location;
  final String category;
  final String status;
}
