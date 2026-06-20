import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({
    super.key,
    required this.pendingTasks,
    required this.urgentTasks,
    required this.onLogout,
  });

  final int pendingTasks;
  final int urgentTasks;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Maintenance Team',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17211C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here is your current task summary.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(Icons.pending_actions, size: 40, color: Colors.orange),
                                const SizedBox(height: 16),
                                Text(
                                  pendingTasks.toString(),
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                ),
                                const Text('My Pending Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.redAccent),
                                const SizedBox(height: 16),
                                Text(
                                  urgentTasks.toString(),
                                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                ),
                                const Text('Urgent Repairs', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.go('/staff/assignments');
                      },
                      icon: const Icon(Icons.assignment),
                      label: const Text('View My Assignments'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
