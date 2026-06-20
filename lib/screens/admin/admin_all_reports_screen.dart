import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/maintenance_report.dart';
import '../../models/report_options.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/urgency_chip.dart';

class AdminAllReportsScreen extends StatefulWidget {
  const AdminAllReportsScreen({super.key, required this.reports});

  final List<MaintenanceReport> reports;

  @override
  State<AdminAllReportsScreen> createState() => _AdminAllReportsScreenState();
}

class _AdminAllReportsScreenState extends State<AdminAllReportsScreen> {
  final _searchController = TextEditingController();

  ReportStatus? _selectedStatus;
  ReportUrgency? _selectedUrgency;
  _ReportSort _sortBy = _ReportSort.newestFirst;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filteredReports();

    final searchText = _searchController.text.trim();
    final hasFilters = _selectedStatus != null ||
        _selectedUrgency != null ||
        searchText.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildControls(),
                Expanded(
                  child: filteredReports.isEmpty
                      ? EmptyState(
                          icon: hasFilters
                              ? Icons.filter_alt_off_rounded
                              : Icons.inbox_rounded,
                          title: hasFilters
                              ? 'No matching reports'
                              : 'No reports yet',
                          message: hasFilters
                              ? 'Try clearing the search or filters to see more results.'
                              : 'New maintenance reports will appear here once students submit them.',
                          action: hasFilters
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedStatus = null;
                                      _selectedUrgency = null;
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.clear_all_rounded),
                                  label: const Text('Clear filters'),
                                )
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return _ReportCard(report: report);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<MaintenanceReport> _filteredReports() {
    final searchText = _searchController.text.trim().toLowerCase();

    final filtered = widget.reports.where((report) {
      final matchesSearch = searchText.isEmpty ||
          report.title.toLowerCase().contains(searchText) ||
          report.location.toLowerCase().contains(searchText) ||
          report.category.label.toLowerCase().contains(searchText) ||
          report.reportId.toLowerCase().contains(searchText);
      final matchesStatus =
          _selectedStatus == null || report.status == _selectedStatus;
      final matchesUrgency =
          _selectedUrgency == null || report.urgency == _selectedUrgency;

      return matchesSearch && matchesStatus && matchesUrgency;
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

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 760;

            final searchField = TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search reports',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            );
            final statusDropdown = DropdownButtonFormField<ReportStatus?>(
              initialValue: _selectedStatus,
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
                setState(() {
                  _selectedStatus = value;
                });
              },
            );
            final urgencyDropdown = DropdownButtonFormField<ReportUrgency?>(
              initialValue: _selectedUrgency,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Urgency'),
              items: [
                const DropdownMenuItem<ReportUrgency?>(
                  value: null,
                  child: Text('All'),
                ),
                ...ReportUrgency.values.map((urgency) {
                  return DropdownMenuItem<ReportUrgency?>(
                    value: urgency,
                    child: Text(urgency.label),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value;
                });
              },
            );
            final sortDropdown = DropdownButtonFormField<_ReportSort>(
              initialValue: _sortBy,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Sort by'),
              items: _ReportSort.values.map((sort) {
                return DropdownMenuItem(value: sort, child: Text(sort.label));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
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
                  urgencyDropdown,
                  const SizedBox(height: 12),
                  sortDropdown,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: statusDropdown),
                    const SizedBox(width: 12),
                    Expanded(child: urgencyDropdown),
                    const SizedBox(width: 12),
                    Expanded(child: sortDropdown),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final MaintenanceReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/admin/reports/${report.reportId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.accent,
                      size: 22,
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.reportId} • ${formatDate(report.submittedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${report.category.label} • ${report.location}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.inkSoft,
                  ),
                ],
              ),
              const SizedBox(height: 14),
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

enum _ReportSort {
  newestFirst('Newest First'),
  oldestFirst('Oldest First'),
  urgency('Urgency'),
  status('Status');

  const _ReportSort(this.label);

  final String label;
}
