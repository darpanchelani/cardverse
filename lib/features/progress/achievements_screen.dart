import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/progress/widgets/achievement_badge_widget.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProgressScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: controller.achievements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 11),
            itemBuilder: (context, index) => AchievementBadgeWidget(
              achievement: controller.achievements[index],
            ),
          ),
        ),
      ),
    );
  }
}
