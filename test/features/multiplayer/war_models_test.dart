import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses sanitized online War state', () {
    final state = WarGameStateModel.fromJson({
      'roomCode': 'AB12CD',
      'gameType': 'war',
      'status': 'battle_over',
      'players': [
        {
          'id': 'one',
          'username': 'One',
          'seatIndex': 0,
          'connectionStatus': 'connected',
        },
        {
          'id': 'two',
          'username': 'Two',
          'seatIndex': 1,
          'connectionStatus': 'connected',
        },
      ],
      'currentBattle': 3,
      'maxBattles': 25,
      'warMode': 'classic',
      'currentBattleCards': {'one': _card('A', 14), 'two': _card('K', 13)},
      'scores': {'one': 2, 'two': 1},
      'cardCounts': {'one': 30, 'two': 22},
      'warCards': const {},
      'battlePileCount': 2,
      'warCount': 0,
      'battleResult': {
        'battleNumber': 3,
        'winnerId': 'one',
        'winnerName': 'One',
        'result': 'player_win',
        'message': 'One wins Battle 3!',
        'cards': {'one': _card('A', 14), 'two': _card('K', 13)},
        'warCards': const {},
        'pileCount': 2,
        'createdAt': '2026-06-12T00:00:00.000Z',
      },
      'battleHistory': const [],
      'rematchRequests': const [],
      'createdAt': '2026-06-12T00:00:00.000Z',
      'updatedAt': '2026-06-12T00:00:01.000Z',
    });

    expect(state.roomCode, 'AB12CD');
    expect(state.currentBattleCards['one']?.rank, 'A');
    expect(state.scores['one'], 2);
    expect(state.cardCounts['two'], 22);
    expect(state.battleResult?.winnerId, 'one');
    expect(state.maxBattles, 25);
  });
}

Map<String, dynamic> _card(String rank, int value) => {
  'suit': 'spades',
  'rank': rank,
  'value': value,
  'displayName': '$rank of Spades',
  'suitSymbol': '♠',
  'colorType': 'black',
};
