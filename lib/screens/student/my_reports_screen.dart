import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _searchController = TextEditingController();

  ReportStatus? _statusFilter;
  _ReportSort _sortBy = _ReportSort.newestFirst;

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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search, filter, and sort your own maintenance reports.',
                style: TextStyle(color: AppColors.inkSoft, fontSize: 15),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 12),
              if (visibleReports.isEmpty)
                const Card(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matching reports',
                    message: 'Try a different search term or clear your filters.',
                  ),
                )
              else
                ...visibleReports.map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportCard(report: report),
                  ),
                ),
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
          report.category.label.toLowerCase().contains(searchText) ||
          report.reportId.toLowerCase().contains(searchText);
      final matchesStatus =
          _statusFilter == null || report.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      return switch (_sortBy) {
        _ReportSort.oldestFirst => a.submittedAt.compareTo(b.submittedAt),
        _ReportSort.urgency => b.urgency.rank.compareTo(a.urgency.rank),
        _ReportSort.status => a.status.label.compareTo(b.status.label),
        _ReportSort.newestFirst => b.submittedAt.compareTo(a.submittedAt),
      };
    });

    return filtered;
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/student/reports/${report.reportId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      size: 20,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.category.label} • ${report.location}',
                          style: const TextStyle(
                            color: AppColors.inkSoft,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${report.reportId} • ${formatDate(report.submittedAt)}',
                          style: const TextStyle(
                            color: AppColors.inkSoft,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
            ],
          ),
        ),
      ),
    );
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
  final ReportStatus? statusFilter;
  final _ReportSort sortBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ReportStatus?> onStatusChanged;
  final ValueChanged<_ReportSort> onSortChanged;

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
            final statusDropdown = DropdownButtonFormField<ReportStatus?>(
              initialValue: statusFilter,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem<ReportStatus?>(
                  value: null,
                  child: Text('All'),
                ),
                ...ReportStatus.values.map((status) {
                  return DropdownMenuItem<ReportStatus?>(
                    value: status,
                    child: Text(status.label),
                  );
                }),
              ],
              onChanged: (value) {
                onStatusChanged(value);
              },
            );
            final sortDropdown = DropdownButtonFormField<_ReportSort>(
              initialValue: sortBy,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: _ReportSort.values.map((sort) {
                return DropdownMenuItem(value: sort, child: Text(sort.label));
              }).toList(),
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

enum _ReportSort {
  newestFirst('Newest First'),
  oldestFirst('Oldest First'),
  urgency('Urgency'),
  status('Status');

  const _ReportSort(this.label);

  final String label;
}
