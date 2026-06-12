import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BlackjackRematchPanelWidget extends StatelessWidget {
  const BlackjackRematchPanelWidget({
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
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.gold),
    ),
    child: Column(
      children: [
        Text(
          'Rematch votes: $requestCount / $humanCount',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: hasRequested || isLoading ? null : onRequest,
          icon: const Icon(Icons.replay_rounded),
          label: Text(
            hasRequested
                ? 'Rematch Requested'
                : isLoading
                ? 'Requesting...'
                : 'Request Rematch',
          ),
        ),
      ],
    ),
  );
}
