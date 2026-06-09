import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _stats = [
    ('Level', '1', Icons.military_tech_outlined),
    ('Coins', '500', Icons.monetization_on_outlined),
    ('Total Games', '0', Icons.style_outlined),
    ('Wins', '0', Icons.emoji_events_outlined),
    ('Losses', '0', Icons.close_rounded),
    ('Win Rate', '0%', Icons.donut_large_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: [
            const CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.gold,
              child: Text(
                'GP',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Arial',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.guestPlayer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Username: ${AppStrings.guestPlayer}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 132,
                  ),
                  itemBuilder: (context, index) {
                    final stat = _stats[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardGreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(stat.$3, color: AppColors.gold, size: 24),
                          const Spacer(),
                          Text(
                            stat.$2,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppColors.paleGold),
                          ),
                          Text(
                            stat.$1,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  fontFamily: 'Arial',
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
