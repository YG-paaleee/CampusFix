import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/header_banner.dart';
import '../../widgets/stat_card.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({
    super.key,
    required this.pendingTasks,
    required this.urgentTasks,
    required this.onLogout,
    this.staffName,
  });

  final int pendingTasks;
  final int urgentTasks;
  final VoidCallback onLogout;
  final String? staffName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Log out?',
                message: 'You will be returned to the login screen.',
                confirmLabel: 'Log out',
              );
              if (ok) onLogout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                HeaderBanner(
                  eyebrow: 'Maintenance Staff',
                  title: 'Welcome, Maintenance Team',
                  subtitle: staffName == null
                      ? 'Here is your current task summary.'
                      : 'Signed in as $staffName • here is your current task summary.',
                  icon: Icons.handyman_outlined,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 520;
                    const spacing = 16.0;

                    final pendingCard = StatCard(
                      label: 'My Pending Tasks',
                      value: pendingTasks.toString(),
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.statusInProgress,
                    );
                    final urgentCard = StatCard(
                      label: 'Urgent Repairs',
                      value: urgentTasks.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.urgencyHigh,
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          pendingCard,
                          const SizedBox(height: spacing),
                          urgentCard,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: pendingCard),
                        const SizedBox(width: spacing),
                        Expanded(child: urgentCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push('/staff/assignments');
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('View My Assignments'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
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
