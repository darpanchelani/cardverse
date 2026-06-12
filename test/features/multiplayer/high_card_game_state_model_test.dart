import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses server High Card state without requiring a deck', () {
    final state = HighCardGameStateModel.fromJson({
      'roomCode': 'AB12CD',
      'gameType': 'high_card',
      'status': 'round_over',
      'players': [
        {
          'id': 'one',
          'username': 'One',
          'avatar': 'default',
          'isHost': true,
          'isReady': true,
          'isBot': false,
          'seatIndex': 0,
          'connectionStatus': 'connected',
        },
        {
          'id': 'two',
          'username': 'Two',
          'avatar': 'default',
          'isHost': false,
          'isReady': true,
          'isBot': false,
          'seatIndex': 1,
          'connectionStatus': 'connected',
        },
      ],
      'currentRound': 1,
      'maxRounds': 5,
      'currentCards': {
        'one': {
          'suit': 'spades',
          'rank': 'A',
          'value': 14,
          'displayName': 'A of Spades',
          'suitSymbol': '♠',
          'colorType': 'black',
        },
        'two': {
          'suit': 'hearts',
          'rank': 'K',
          'value': 13,
          'displayName': 'K of Hearts',
          'suitSymbol': '♥',
          'colorType': 'red',
        },
      },
      'scores': {'one': 1, 'two': 0},
      'roundResult': {
        'roundNumber': 1,
        'winnerId': 'one',
        'winnerName': 'One',
        'result': 'player_win',
        'message': 'One wins Round 1!',
        'cards': {
          'one': {
            'suit': 'spades',
            'rank': 'A',
            'value': 14,
            'displayName': 'A of Spades',
            'suitSymbol': '♠',
            'colorType': 'black',
          },
          'two': {
            'suit': 'hearts',
            'rank': 'K',
            'value': 13,
            'displayName': 'K of Hearts',
            'suitSymbol': '♥',
            'colorType': 'red',
          },
        },
        'createdAt': '2026-06-10T00:00:00.000Z',
      },
      'roundHistory': [],
      'matchWinner': null,
      'rematchRequests': [],
      'createdAt': '2026-06-10T00:00:00.000Z',
      'updatedAt': '2026-06-10T00:00:01.000Z',
    });

    expect(state.roomCode, 'AB12CD');
    expect(state.currentCards['one']?.rank, 'A');
    expect(state.currentCards['two']?.value, 13);
    expect(state.roundResult?.winnerId, 'one');
    expect(state.scores['one'], 1);
  });
}
