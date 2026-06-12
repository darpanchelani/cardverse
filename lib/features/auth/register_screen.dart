import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/core/widgets/custom_text_field.dart';
import 'package:cardverse/features/auth/local_auth_service.dart';
import 'package:cardverse/features/auth/local_account_model.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create your player',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your account is saved locally on this device.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    label: 'Full name',
                    icon: Icons.badge_outlined,
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Username',
                    icon: Icons.alternate_email_rounded,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Confirm password',
                    icon: Icons.verified_user_outlined,
                    controller: _confirmPasswordController,
                    obscureText: true,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    label: _isLoading ? 'Creating Account...' : 'Register',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isLoading ? null : _register,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.go(AppRoutes.login),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final validationError = _validate(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final storage = await LocalStorageService.create();
    late final LocalAccountModel account;
    try {
      account = await LocalAuthService(storage).register(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
      );
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
      return;
    }
    if (!mounted) return;
    final progress = ProgressScope.of(context);
    await progress.switchAccount(
      accountId: account.id,
      username: account.username,
    );
    if (!mounted) return;
    MultiplayerScope.of(context).connection.updateIdentity(
      username: account.username,
      level: progress.profile.level,
    );
    context.go(AppRoutes.home);
  }

  String? _validate({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if ([
      fullName,
      username,
      email,
      password,
      confirmPassword,
    ].any((value) => value.isEmpty)) {
      return 'Complete all fields.';
    }
    if (username.length < 3) return 'Username must be at least 3 characters.';
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(username)) {
      return 'Username can only use letters, numbers, and underscores.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (password != confirmPassword) return 'Passwords do not match.';
    return null;
  }
}
