import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.gold),
        if (label != null) ...[const SizedBox(height: 14), Text(label!)],
      ],
    ),
  );
}
