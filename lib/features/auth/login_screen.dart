import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/core/widgets/custom_text_field.dart';
import 'package:cardverse/features/auth/local_auth_service.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 42),
                  const _AuthMark(),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your locally saved CardVerse account.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 38),
                  CustomTextField(
                    label: 'Email or username',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passwordController,
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
                    label: _isLoading ? 'Signing In...' : 'Login',
                    icon: Icons.login_rounded,
                    onPressed: _isLoading ? null : _login,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'Continue as Guest',
                    icon: Icons.person_outline_rounded,
                    isOutlined: true,
                    onPressed: _isLoading ? null : _continueAsGuest,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.push(AppRoutes.register),
                    child: const Text('Create New Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final storage = await LocalStorageService.create();
    final account = await LocalAuthService(
      storage,
    ).login(email: email, password: password);
    if (!mounted) return;
    if (account == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Account not found or password is incorrect. Create an account first.';
      });
      return;
    }
    await _applyIdentity(accountId: account.id, username: account.username);
  }

  Future<void> _continueAsGuest() async {
    final storage = await LocalStorageService.create();
    await LocalAuthService(storage).continueAsGuest();
    if (!mounted) return;
    await _applyIdentity(accountId: 'guest', username: 'Guest Player');
  }

  Future<void> _applyIdentity({
    required String accountId,
    required String username,
  }) async {
    final progress = ProgressScope.of(context);
    await progress.switchAccount(accountId: accountId, username: username);
    if (!mounted) return;
    MultiplayerScope.of(context).connection.updateIdentity(
      username: username,
      level: progress.profile.level,
    );
    context.go(AppRoutes.home);
  }
}

class _AuthMark extends StatelessWidget {
  const _AuthMark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircleAvatar(
        radius: 42,
        backgroundColor: AppColors.gold,
        child: Icon(Icons.style_rounded, size: 40, color: AppColors.ink),
      ),
    );
  }
}
