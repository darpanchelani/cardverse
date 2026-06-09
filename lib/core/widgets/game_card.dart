import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    required this.name,
    required this.icon,
    required this.isLocked,
    required this.onTap,
    super.key,
    this.onLockedTap,
  });

  final String name;
  final IconData icon;
  final bool isLocked;
  final VoidCallback onTap;
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !isLocked,
      label: isLocked ? '$name, coming soon' : name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? onLockedTap : onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.cardGreen.withValues(alpha: 0.55)
                  : AppColors.cardGreen,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isLocked
                    ? AppColors.border.withValues(alpha: 0.5)
                    : AppColors.gold.withValues(alpha: 0.45),
              ),
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  top: -16,
                  child: Icon(
                    icon,
                    size: 88,
                    color: AppColors.white.withValues(alpha: 0.035),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isLocked
                              ? AppColors.inputGreen
                              : AppColors.gold,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isLocked ? Icons.lock_rounded : icon,
                          color: isLocked ? AppColors.mutedText : AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isLocked
                              ? AppColors.mutedText
                              : AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isLocked ? 'Coming Soon' : 'Ready to play',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isLocked
                              ? AppColors.mutedText
                              : AppColors.gold,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
