import 'dart:async';

import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/auth/services/google_auth_service.dart';
import 'package:cardverse/features/auth/widgets/google_sign_in_button.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.googleAuth});

  final GoogleAuthGateway? googleAuth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GoogleAuthGateway _googleAuth;
  StreamSubscription<String>? _googleTokenSubscription;
  bool _googleReady = false;
  bool _googleRequestInFlight = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _googleAuth = widget.googleAuth ?? GoogleAuthService.instance;
    if (kIsWeb) {
      _googleTokenSubscription = _googleAuth.idTokens.listen(
        _finishGoogleSignIn,
        onError: _showGoogleError,
      );
    }
    unawaited(_initializeGoogle());
  }

  @override
  void dispose() {
    _googleTokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -42,
            right: -28,
            child: _DecorativeSuit(
              icon: Icons.favorite_rounded,
              size: 180,
              rotation: 0.16,
            ),
          ),
          const Positioned(
            bottom: -54,
            left: -26,
            child: _DecorativeSuit(
              icon: Icons.change_history_rounded,
              size: 200,
              rotation: -0.12,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 20 : 36,
                    vertical: compact ? 22 : 48,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (compact ? 44 : 96),
                    ),
                    child: Center(
                      child: Container(
                        width: 500,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 24 : 40,
                          compact ? 30 : 42,
                          compact ? 24 : 40,
                          compact ? 28 : 38,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardGreen.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x45000000),
                              blurRadius: 42,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _AuthMark(),
                            const SizedBox(height: 28),
                            Text(
                              'Your table is ready',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pick up where you left off, or jump straight '
                              'into a game as a guest.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.mutedText,
                                    height: 1.45,
                                  ),
                            ),
                            const SizedBox(height: 32),
                            if (_isLoading && _googleRequestInFlight)
                              const _GoogleLoadingButton()
                            else if (_googleReady)
                              GoogleSignInButton(
                                onPressed: _isLoading
                                    ? null
                                    : _startGoogleSignIn,
                              )
                            else if (_errorMessage != null)
                              const _GoogleUnavailableButton()
                            else
                              const _GoogleLoadingButton(
                                label: 'Preparing Google sign-in…',
                              ),
                            const SizedBox(height: 18),
                            const _ChoiceDivider(),
                            const SizedBox(height: 18),
                            CustomButton(
                              label: 'Play as guest',
                              icon: Icons.person_outline_rounded,
                              isOutlined: true,
                              onPressed: _isLoading ? null : _continueAsGuest,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Guest progress stays on this device.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 18),
                              _InlineError(message: _errorMessage!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeGoogle() async {
    try {
      await _googleAuth.initialize();
      if (!mounted) return;
      setState(() => _googleReady = true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _googleReady = false;
        _errorMessage = _messageForGoogleError(error);
      });
    }
  }

  Future<void> _startGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _googleRequestInFlight = true;
      _errorMessage = null;
    });
    try {
      final idToken = await _googleAuth.authenticate();
      await _finishGoogleSignIn(idToken);
    } catch (error) {
      _showGoogleError(error);
    }
  }

  Future<void> _finishGoogleSignIn(String idToken) async {
    if (_googleRequestInFlight && kIsWeb) return;
    _googleRequestInFlight = true;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final auth = AuthScope.of(context);
    final success = await auth.loginWithGoogle(idToken: idToken);
    if (!mounted) return;
    if (!success) {
      setState(() {
        _isLoading = false;
        _googleRequestInFlight = false;
        _errorMessage = auth.errorMessage;
      });
      return;
    }
    await _applyIdentity(auth);
  }

  void _showGoogleError(Object error) {
    if (!mounted) return;
    final canceled =
        error is GoogleSignInException &&
        (error.code == GoogleSignInExceptionCode.canceled ||
            error.code == GoogleSignInExceptionCode.interrupted);
    setState(() {
      _isLoading = false;
      _googleRequestInFlight = false;
      _errorMessage = canceled ? null : _messageForGoogleError(error);
    });
  }

  String _messageForGoogleError(Object error) {
    if (error is StateError || error is UnsupportedError) {
      return error.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    }
    if (error is GoogleSignInException && error.description != null) {
      return error.description!;
    }
    return 'Google sign-in is unavailable right now. You can still play as a guest.';
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
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
    return Center(
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33F0C45A),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.style_rounded, size: 40, color: AppColors.ink),
      ),
    );
  }
}

class _ChoiceDivider extends StatelessWidget {
  const _ChoiceDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.mutedText,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _GoogleLoadingButton extends StatelessWidget {
  const _GoogleLoadingButton({this.label = 'Signing in with Google…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4285F4),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF3C4043))),
        ],
      ),
    );
  }
}

class _GoogleUnavailableButton extends StatelessWidget {
  const _GoogleUnavailableButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFB9C0BC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'G',
            style: TextStyle(
              color: Color(0xFF5F6368),
              fontSize: 21,
              fontWeight: FontWeight.w800,
              fontFamily: 'Arial',
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: TextStyle(color: Color(0xFF5F6368)),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeSuit extends StatelessWidget {
  const _DecorativeSuit({
    required this.icon,
    required this.size,
    required this.rotation,
  });

  final IconData icon;
  final double size;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          icon,
          size: size,
          color: AppColors.gold.withValues(alpha: 0.035),
        ),
      ),
    );
  }
}
