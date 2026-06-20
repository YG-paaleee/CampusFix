import 'package:flutter/material.dart';
import '../../models/staff_account.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';

class AdminStaffManagementScreen extends StatelessWidget {
  const AdminStaffManagementScreen({
    super.key,
    required this.staffMembers,
    required this.onAddStaff,
    required this.onToggleStatus,
    required this.onEditStaff,
  });

  final List<StaffAccount> staffMembers;
  final ValueChanged<StaffAccount> onAddStaff;
  final ValueChanged<String> onToggleStatus;
  final void Function(String, String, String) onEditStaff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maintenance Staff',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage staff accounts, availability, and assignments.',
                  style: TextStyle(fontSize: 16, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 24),
                if (staffMembers.isEmpty)
                  EmptyState(
                    icon: Icons.groups_rounded,
                    title: 'No staff members yet',
                    message: 'Add your first maintenance staff member to start assigning reports.',
                    action: FilledButton.icon(
                      onPressed: () => _showAddStaffDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Staff'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800
                          ? 3
                          : (constraints.maxWidth > 600 ? 2 : 1);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: staffMembers.length,
                        itemBuilder: (context, index) {
                          return _StaffCard(
                            staff: staffMembers[index],
                            onToggleStatus: onToggleStatus,
                            onEditStaff: onEditStaff,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddStaffDialog(onAddStaff: onAddStaff),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.onToggleStatus,
    required this.onEditStaff,
  });

  final StaffAccount staff;
  final ValueChanged<String> onToggleStatus;
  final void Function(String, String, String) onEditStaff;

  String get _initials {
    final parts = staff.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.brandSoft,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          staff.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusPill(isActive: staff.isActive),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.specialty,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.email,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showEditStaffDialog(context),
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                        color: AppColors.inkSoft,
                        tooltip: 'Edit staff',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: staff.isActive,
                          onChanged: (_) => onToggleStatus(staff.staffId),
                          activeColor: AppColors.brand,
                        ),
                      ),
                      Text(
                        staff.isActive ? 'Active' : 'Disabled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: staff.isActive ? AppColors.statusResolved : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditStaffDialog(staff: staff, onEditStaff: onEditStaff),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive ? AppColors.statusResolvedBg : AppColors.border;
    final Color fg = isActive ? AppColors.statusResolved : AppColors.inkSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AddStaffDialog extends StatefulWidget {
  const _AddStaffDialog({required this.onAddStaff});

  final ValueChanged<StaffAccount> onAddStaff;

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedSpecialty = 'General Maintenance';

  final _specialties = [
    'General Maintenance',
    'Electrician',
    'Plumber',
    'IT Support',
    'Janitorial',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newStaff = StaffAccount(
        staffId: 's${DateTime.now().millisecondsSinceEpoch}', // Mock ID generation
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        specialty: _selectedSpecialty,
        isActive: true,
      );
      widget.onAddStaff(newStaff);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Staff'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                validator: (value) => value == null || !value.contains('@') ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(labelText: 'Specialty'),
                items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSpecialty = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save Staff'),
        ),
      ],
    );
  }
}

class _EditStaffDialog extends StatefulWidget {
  const _EditStaffDialog({required this.staff, required this.onEditStaff});

  final StaffAccount staff;
  final void Function(String, String, String) onEditStaff;

  @override
  State<_EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<_EditStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedSpecialty;

  final _specialties = [
    'General Maintenance',
    'Electrician',
    'Plumber',
    'IT Support',
    'Janitorial',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.fullName);
    _selectedSpecialty = _specialties.contains(widget.staff.specialty)
        ? widget.staff.specialty
        : _specialties.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onEditStaff(
        widget.staff.staffId,
        _nameController.text.trim(),
        _selectedSpecialty,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Staff'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              Text(
                widget.staff.email,
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: const InputDecoration(labelText: 'Specialty'),
                items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSpecialty = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
