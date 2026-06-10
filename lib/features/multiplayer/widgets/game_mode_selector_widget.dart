import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GameModeSelectorWidget extends StatelessWidget {
  const GameModeSelectorWidget({
    required this.selectedGameType,
    required this.onChanged,
    super.key,
  });

  final String selectedGameType;
  final ValueChanged<String> onChanged;

  static const games = [
    ('high_card', 'High Card', Icons.filter_1_rounded),
    ('war', 'War', Icons.local_fire_department_rounded),
    ('blackjack', 'Blackjack', Icons.casino_rounded),
  ];

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 9,
    runSpacing: 9,
    children: games.map((game) {
      final selected = selectedGameType == game.$1;
      return ChoiceChip(
        avatar: Icon(
          game.$3,
          size: 18,
          color: selected ? AppColors.ink : AppColors.gold,
        ),
        label: Text(game.$2),
        selected: selected,
        onSelected: (_) => onChanged(game.$1),
        selectedColor: AppColors.gold,
        backgroundColor: AppColors.cardGreen,
        side: const BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          color: selected ? AppColors.ink : AppColors.white,
          fontFamily: 'Arial',
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList(),
  );
}
