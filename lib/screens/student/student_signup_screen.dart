import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../utils/student_identity.dart';

typedef StudentRegistrationHandler =
    Future<String?> Function({
      required String fullName,
      required String studentId,
      required String email,
      required String password,
    });

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key, required this.onStudentRegistered});

  final StudentRegistrationHandler onStudentRegistered;

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _studentIdController.addListener(_updateEmailFromStudentId);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateEmailFromStudentId() {
    final studentId = _studentIdController.text.trim();
    final email = isValidStudentId(studentId)
        ? emailFromStudentId(studentId)
        : '';

    if (_emailController.text == email) {
      return;
    }

    _emailController.text = email;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final errorMessage = await widget.onStudentRegistered(
      fullName: _fullNameController.text,
      studentId: _studentIdController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      setState(() {
        _isLoading = false;
        _errorText = errorMessage;
      });
      return;
    }

    context.go('/student');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Student Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.brandSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.brand,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Student Registration',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account so your maintenance reports are '
                          'saved under your student profile.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.inkSoft, height: 1.4),
                        ),
                        const SizedBox(height: 28),
                        const _FieldLabel('Full name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'Juan Dela Cruz',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: _requiredField,
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Student ID'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _studentIdController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: '2023-8-0099',
                            helperText: 'Format: 2023-8-0099',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'This field is required.';
                            }
                            if (!isValidStudentId(text)) {
                              return 'Use the format 2023-8-0099.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('School email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true,
                          decoration: const InputDecoration(
                            helperText: 'Generated from your student ID.',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'This field is required.';
                            }
                            if (!text.contains('@')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'At least 6 characters',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if ((value ?? '').length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Confirm password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Re-enter your password',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusRejectedBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.statusRejected,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      color: AppColors.statusRejected,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _createAccount,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(
                            _isLoading ? 'Creating...' : 'Create Account',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.go('/'),
                          child: const Text('Back to login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
