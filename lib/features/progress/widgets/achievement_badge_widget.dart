import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/utils/date_time_utils.dart';
import 'package:cardverse/features/progress/models/achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementBadgeWidget extends StatelessWidget {
  const AchievementBadgeWidget({
    required this.achievement,
    super.key,
    this.compact = false,
  });

  final AchievementModel achievement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Container(
      padding: EdgeInsets.all(compact ? 13 : 16),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.cardGreen
            : AppColors.cardGreen.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: unlocked ? AppColors.gold : AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: compact ? 22 : 26,
            backgroundColor: unlocked ? AppColors.gold : AppColors.inputGreen,
            child: Icon(
              unlocked ? _iconFor(achievement.icon) : Icons.lock_rounded,
              color: unlocked ? AppColors.ink : AppColors.mutedText,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: unlocked ? AppColors.white : AppColors.mutedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  unlocked && achievement.unlockedAt != null
                      ? 'Unlocked ${DateTimeUtils.formatDate(achievement.unlockedAt!)}'
                      : '+${achievement.rewardCoins} coins • +${achievement.rewardXp} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: unlocked ? AppColors.gold : AppColors.mutedText,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String icon) {
    return switch (icon) {
      'trophy' => Icons.emoji_events_rounded,
      'cards' => Icons.style_rounded,
      'fire' => Icons.local_fire_department_rounded,
      'casino' => Icons.casino_rounded,
      'sparkles' => Icons.auto_awesome_rounded,
      'crown' => Icons.military_tech_rounded,
      'calendar' => Icons.calendar_month_rounded,
      'coins' => Icons.monetization_on_rounded,
      _ => Icons.star_rounded,
    };
  }
}
