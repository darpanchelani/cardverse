import 'package:flutter/material.dart';

class BlackjackMultiplayerActionButtonsWidget extends StatelessWidget {
  const BlackjackMultiplayerActionButtonsWidget({
    required this.status,
    required this.canAct,
    required this.isHost,
    required this.connected,
    required this.isBusy,
    required this.onStartRound,
    required this.onHit,
    required this.onStand,
    required this.onNextRound,
    super.key,
  });

  final String status;
  final bool canAct;
  final bool isHost;
  final bool connected;
  final bool isBusy;
  final VoidCallback onStartRound;
  final VoidCallback onHit;
  final VoidCallback onStand;
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    if (status == 'betting') {
      return FilledButton.icon(
        onPressed: connected && isHost && !isBusy ? onStartRound : null,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(
          isHost
              ? isBusy
                    ? 'Dealing...'
                    : 'Start Round'
              : 'Waiting for host',
        ),
      );
    }
    if (status == 'playing') {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: connected && canAct && !isBusy ? onHit : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Hit'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: connected && canAct && !isBusy ? onStand : null,
              icon: const Icon(Icons.pan_tool_alt_outlined),
              label: const Text('Stand'),
            ),
          ),
        ],
      );
    }
    if (status == 'dealer_turn') {
      return const FilledButton(
        onPressed: null,
        child: Text('Dealer is playing...'),
      );
    }
    if (status == 'round_over') {
      return FilledButton.icon(
        onPressed: connected && !isBusy ? onNextRound : null,
        icon: const Icon(Icons.skip_next_rounded),
        label: Text(isBusy ? 'Preparing...' : 'Next Round'),
      );
    }
    return const SizedBox.shrink();
  }
}
