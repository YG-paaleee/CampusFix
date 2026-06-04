import 'package:flutter/material.dart';

import '../../models/maintenance_report.dart';
import 'report_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _searchController = TextEditingController();

  String _statusFilter = 'All';
  String _sortBy = 'Newest First';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleReports = _filteredReports();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Submitted Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search, filter, and sort your own maintenance reports.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF506158)),
              ),
              const SizedBox(height: 18),
              _ReportControls(
                searchController: _searchController,
                statusFilter: _statusFilter,
                sortBy: _sortBy,
                onSearchChanged: (_) => setState(() {}),
                onStatusChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                  });
                },
                onSortChanged: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${visibleReports.length} report${visibleReports.length == 1 ? '' : 's'} found',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (visibleReports.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No reports match your search or filter.'),
                  ),
                )
              else
                ...visibleReports.map((report) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEAF2EE),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          child: const Icon(Icons.build, size: 20),
                        ),
                        title: Text(
                          report.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${report.category} - ${report.location}\nUrgency: ${report.urgency} - ${report.reportId} - ${_formatDate(report.submittedAt)}',
                        ),
                        trailing: _StatusChip(status: report.status),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReportDetailScreen(report: report),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  List<MaintenanceReport> _filteredReports() {
    final searchText = _searchController.text.trim().toLowerCase();

    final filtered = widget.reports.where((report) {
      final matchesSearch =
          searchText.isEmpty ||
          report.title.toLowerCase().contains(searchText) ||
          report.location.toLowerCase().contains(searchText) ||
          report.category.toLowerCase().contains(searchText) ||
          report.reportId.toLowerCase().contains(searchText);
      final matchesStatus =
          _statusFilter == 'All' || report.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      return switch (_sortBy) {
        'Oldest First' => a.submittedAt.compareTo(b.submittedAt),
        'Urgency' => _urgencyRank(b.urgency).compareTo(_urgencyRank(a.urgency)),
        'Status' => a.status.compareTo(b.status),
        _ => b.submittedAt.compareTo(a.submittedAt),
      };
    });

    return filtered;
  }

  int _urgencyRank(String urgency) {
    return switch (urgency) {
      'High' => 3,
      'Medium' => 2,
      _ => 1,
    };
  }
}

class _ReportControls extends StatelessWidget {
  const _ReportControls({
    required this.searchController,
    required this.statusFilter,
    required this.sortBy,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String statusFilter;
  final String sortBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;

            final searchField = TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search reports',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: onSearchChanged,
            );
            final statusDropdown = DropdownButtonFormField<String>(
              initialValue: statusFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Submitted', child: Text('Submitted')),
                DropdownMenuItem(
                  value: 'In Progress',
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onStatusChanged(value);
                }
              },
            );
            final sortDropdown = DropdownButtonFormField<String>(
              initialValue: sortBy,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: const [
                DropdownMenuItem(
                  value: 'Newest First',
                  child: Text('Newest First'),
                ),
                DropdownMenuItem(
                  value: 'Oldest First',
                  child: Text('Oldest First'),
                ),
                DropdownMenuItem(value: 'Urgency', child: Text('Urgency')),
                DropdownMenuItem(value: 'Status', child: Text('Status')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onSortChanged(value);
                }
              },
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  statusDropdown,
                  const SizedBox(height: 12),
                  sortDropdown,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                SizedBox(width: 210, child: statusDropdown),
                const SizedBox(width: 12),
                SizedBox(width: 220, child: sortDropdown),
              ],
            );
          },
        ),
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

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
