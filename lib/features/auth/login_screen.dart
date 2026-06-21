import 'package:cardverse/app/routes.dart';
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/core/widgets/custom_text_field.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
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
                    'Sign in to your CardVerse cloud account.',
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
    final auth = AuthScope.of(context);
    final success = await auth.login(email: email, password: password);
    if (!mounted) return;
    if (!success) {
      setState(() {
        _isLoading = false;
        _errorMessage = auth.errorMessage;
      });
      return;
    }
    await _applyIdentity(auth);
  }

  Future<void> _continueAsGuest() async {
    final auth = AuthScope.of(context);
    await auth.continueAsGuest();
    if (!mounted) return;
    await _applyIdentity(auth);
  }

  Future<void> _applyIdentity(AuthController auth) async {
    final progress = ProgressScope.of(context);
    await progress.switchAccount(
      accountId: auth.isAuthenticated ? auth.user!.id : 'guest',
      username: auth.identityUsername,
    );
    if (!mounted) return;
    final multiplayer = MultiplayerScope.of(context);
    multiplayer.updateIdentity(
      userId: auth.isAuthenticated
          ? auth.user!.id
          : MultiplayerScope.of(context).connection.userId,
      username: auth.identityUsername,
      level: auth.isAuthenticated ? auth.identityLevel : progress.profile.level,
      avatar: auth.identityAvatar,
      token: auth.token,
    );
    final services = AppServicesScope.maybeOf(context);
    if (auth.isAuthenticated && services != null) {
      await multiplayer.connection.connect();
      await Future.wait([
        services.notifications.loadNotifications(),
        services.invites.loadInvites(),
        services.customization.loadThemes(),
      ]);
    } else {
      services?.notifications.clear();
      services?.invites.clear();
      await services?.customization.loadThemes();
    }
    if (!mounted) return;
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
