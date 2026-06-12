import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RematchPanelWidget extends StatelessWidget {
  const RematchPanelWidget({
    required this.hasRequested,
    required this.requestCount,
    required this.humanCount,
    required this.isLoading,
    required this.onRequest,
    super.key,
  });

  final bool hasRequested;
  final int requestCount;
  final int humanCount;
  final bool isLoading;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Rematch', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          '$requestCount of $humanCount players accepted',
          style: const TextStyle(
            color: AppColors.mutedText,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: hasRequested || isLoading ? null : onRequest,
          icon: Icon(
            hasRequested ? Icons.hourglass_top_rounded : Icons.replay_rounded,
          ),
          label: Text(
            hasRequested
                ? 'Waiting for Players'
                : isLoading
                ? 'Requesting...'
                : 'Request Rematch',
          ),
        ),
      ],
    ),
  );
}
