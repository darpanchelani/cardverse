import 'dart:async';

import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/constants/app_strings.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _minimumDisplayTimer;
  bool _minimumDisplayElapsed = false;
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _minimumDisplayTimer = Timer(const Duration(seconds: 2), () {
      _minimumDisplayElapsed = true;
      _navigateIfReady();
    });
    unawaited(_loadOnboardingStatus());
  }

  Future<void> _loadOnboardingStatus() async {
    final storage = await LocalStorageService.create();
    _hasSeenOnboarding =
        await storage.getBool(StorageKeys.hasSeenOnboarding) ?? false;
    _navigateIfReady();
  }

  void _navigateIfReady() {
    if (!mounted || !_minimumDisplayElapsed || _hasSeenOnboarding == null) {
      return;
    }
    context.go(_hasSeenOnboarding! ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _minimumDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [AppColors.tableGreen, AppColors.deepGreen],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.gold, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'V',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 54,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 9,
                      child: Text(
                        'A♠',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 9,
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: Text(
                          'A♠',
                          style: TextStyle(
                            color: AppColors.deepGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text(
                AppStrings.appName,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(color: AppColors.paleGold),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.tagline,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 54),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
