import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef StudentLoginHandler =
    bool Function({required String identifier, required String password});

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onStudentLogin});

  final StudentLoginHandler onStudentLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _LoginTopBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 820;

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _LoginIntro(),
                            const SizedBox(height: 24),
                            _LoginCard(onStudentLogin: onStudentLogin),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _LoginIntro()),
                          const SizedBox(width: 32),
                          SizedBox(
                            width: 420,
                            child: _LoginCard(onStudentLogin: onStudentLogin),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const _LoginFooter(),
        ],
      ),
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E7E1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const _UniversityMark(size: 42),
          const SizedBox(width: 12),
          Text(
            'CampusFix',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2EE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'PSU Portal',
              style: TextStyle(
                color: Color(0xFF114B3A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginIntro extends StatelessWidget {
  const _LoginIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2EE),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'STUDENT MAINTENANCE PORTAL',
            style: TextStyle(
              color: Color(0xFF114B3A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Submit and monitor campus maintenance concerns',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17211C),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A complaint-style maintenance portal for Palawan State University facilities, classrooms, restrooms, and equipment.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            height: 1.5,
            color: const Color(0xFF506158),
          ),
        ),
        const SizedBox(height: 22),
        const _PortalNotice(),
        const SizedBox(height: 18),
        const _IntroPoint(icon: Icons.assignment, text: 'File repair requests'),
        const _IntroPoint(icon: Icons.timeline, text: 'Track report status'),
        const _IntroPoint(icon: Icons.verified, text: 'View staff updates'),
      ],
    );
  }
}

class _LoginCard extends StatefulWidget {
  const _LoginCard({required this.onStudentLogin});

  final StudentLoginHandler onStudentLogin;

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final loginSucceeded = widget.onStudentLogin(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );

    if (!loginSucceeded) {
      setState(() {
        _errorText = 'Enter your student ID/email and password.';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    context.go('/student');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Student Login',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Use your student account to continue.'),
            const SizedBox(height: 20),
            TextField(
              controller: _identifierController,
              decoration: const InputDecoration(
                labelText: 'School email or student ID',
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              onSubmitted: (_) => _login(),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login),
              label: const Text('Login as Student'),
            ),
            const SizedBox(height: 12),
            Text(
              'Not a student?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    context.push('/admin-login');
                  },
                  child: const Text('Admin Login'),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/staff-login');
                  },
                  child: const Text('Staff Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalNotice extends StatelessWidget {
  const _PortalNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Use this portal for campus maintenance concerns. For immediate safety emergencies, contact campus security or the proper office first.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPoint extends StatelessWidget {
  const _IntroPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      color: const Color(0xFF0B1F18),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_city, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Palawan State University',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'Campus maintenance request system',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UniversityMark extends StatelessWidget {
  const _UniversityMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        'PSU',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
