import 'package:flutter/material.dart';

import 'my_reports_screen.dart';
import 'submit_report_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CampusFix')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Student Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your campus maintenance requests.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: _StatusCard(label: 'Submitted', value: '0')),
              SizedBox(width: 12),
              Expanded(child: _StatusCard(label: 'In Progress', value: '0')),
              SizedBox(width: 12),
              Expanded(child: _StatusCard(label: 'Resolved', value: '0')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubmitReportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Submit Report'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyReportsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('My Reports'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
