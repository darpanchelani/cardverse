import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isOutlined = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: AppColors.paleGold,
            side: const BorderSide(color: AppColors.gold),
            minimumSize: const Size(0, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          )
        : FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.ink,
            minimumSize: const Size(0, 54),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );

    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
            label: Text(label),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
            label: Text(label),
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
