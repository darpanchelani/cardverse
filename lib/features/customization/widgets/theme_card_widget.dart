import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/customization/models/cosmetic_item_model.dart';
import 'package:flutter/material.dart';

class ThemeCardWidget extends StatelessWidget {
  const ThemeCardWidget({
    required this.item,
    required this.onPurchase,
    required this.onEquip,
    super.key,
  });

  final CosmeticItemModel item;
  final VoidCallback? onPurchase;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: _gradient(item.id),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: item.isEquipped ? AppColors.gold : AppColors.border,
                  width: item.isEquipped ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                _icon(item.type),
                size: 44,
                color: AppColors.paleGold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(item.name, style: Theme.of(context).textTheme.titleMedium),
          Text(
            item.price == 0 ? 'Free' : '${item.price} coins',
            style: const TextStyle(color: AppColors.gold),
          ),
          const SizedBox(height: 8),
          if (item.isEquipped)
            const Chip(label: Text('Equipped'))
          else if (item.isUnlocked)
            OutlinedButton(onPressed: onEquip, child: const Text('Equip'))
          else
            FilledButton(onPressed: onPurchase, child: const Text('Unlock')),
        ],
      ),
    ),
  );

  static LinearGradient _gradient(String id) => LinearGradient(
    colors: switch (id) {
      'royal_gold' ||
      'royal_table' => const [Color(0xFF2E2411), Color(0xFFE6B94F)],
      'neon_night' ||
      'night_casino' => const [Color(0xFF080A18), Color(0xFF3B4DD8)],
      'desert_thar' ||
      'desert_table' => const [Color(0xFF4A2D18), Color(0xFFC89147)],
      'minimal_dark' => const [Color(0xFF090B0B), Color(0xFF343A38)],
      _ => const [AppColors.tableGreen, AppColors.inputGreen],
    },
  );

  static IconData _icon(String type) => switch (type) {
    'tableTheme' => Icons.casino_outlined,
    'avatarFrame' => Icons.account_circle_outlined,
    _ => Icons.style_outlined,
  };
}
