import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      title: 'Play Classic Card Games',
      subtitle: 'Enjoy War, Blackjack, Rummy, Teen Patti and more.',
      icon: Icons.style_rounded,
      symbol: 'A♠',
    ),
    _OnboardingData(
      title: 'Play With Computer',
      subtitle: 'Practice anytime against smart bots.',
      icon: Icons.smart_toy_rounded,
      symbol: 'K♦',
    ),
    _OnboardingData(
      title: 'Play With Friends',
      subtitle: 'Create rooms, invite friends and play online.',
      icon: Icons.groups_rounded,
      symbol: 'Q♣',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_currentPage == _pages.length - 1) {
      await _completeOnboarding();
      if (!mounted) return;
      context.go(AppRoutes.login);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() async {
    await _completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _completeOnboarding() async {
    final storage = await LocalStorageService.create();
    await storage.saveBool(StorageKeys.hasSeenOnboarding, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _skip, child: const Text('Skip')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  itemBuilder: (context, index) =>
                      _OnboardingPage(data: _pages[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentPage == index ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.gold
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomButton(
                  label: _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tableGreen,
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                Transform.rotate(
                  angle: -0.12,
                  child: Container(
                    width: 132,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 25,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        data.symbol,
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 31,
                  bottom: 24,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.gold,
                    child: Icon(data.icon, color: AppColors.ink, size: 34),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.symbol,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String symbol;
}
