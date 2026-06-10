import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:cardverse/features/multiplayer/services/room_code_service.dart';

class DummyRoomService {
  DummyRoomService(this._roomCodeService);

  // TODO: Replace with SocketRoomService in Phase 7.
  final RoomCodeService _roomCodeService;
  final Map<String, RoomModel> _rooms = {};

  Future<RoomModel> createRoom({
    required String gameType,
    required String gameName,
    required int maxPlayers,
    required bool isPrivate,
    required bool allowBots,
    required bool allowChat,
    required Map<String, dynamic> settings,
  }) async {
    final code = _uniqueCode();
    final room = RoomModel(
      roomCode: code,
      roomName: 'Guest Player\'s Table',
      gameType: gameType,
      gameName: gameName,
      roomType: isPrivate ? 'private' : 'public',
      maxPlayers: maxPlayers,
      players: const [
        RoomPlayerModel(
          id: 'current_user',
          username: 'Guest Player',
          avatar: 'GP',
          isHost: true,
          isReady: false,
          isBot: false,
          seatIndex: 0,
          connectionStatus: 'connected',
        ),
      ],
      allowBots: allowBots,
      allowChat: allowChat,
      isPrivate: isPrivate,
      status: 'waiting',
      createdAt: DateTime.now(),
      settings: settings,
    );
    _rooms[code] = room;
    return room;
  }

  Future<RoomModel> joinRoom(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    var room = _rooms[code] ?? _joinedRoom(code);
    if (room.isFull &&
        !room.players.any((player) => player.id == 'current_user')) {
      throw StateError('This room is full.');
    }
    if (!room.players.any((player) => player.id == 'current_user')) {
      room = room.copyWith(
        players: [
          ...room.players,
          RoomPlayerModel(
            id: 'current_user',
            username: 'Guest Player',
            avatar: 'GP',
            isHost: false,
            isReady: false,
            isBot: false,
            seatIndex: _firstEmptySeat(room),
            connectionStatus: 'connected',
          ),
        ],
      );
    }
    _rooms[code] = room;
    return room;
  }

  Future<void> leaveRoom(String roomCode) async {
    final room = _rooms[roomCode];
    if (room == null) return;
    _rooms[roomCode] = room.copyWith(
      players: room.players
          .where((player) => player.id != 'current_user')
          .toList(),
    );
  }

  Future<RoomModel> toggleReady(RoomModel room, String playerId) async {
    final players = room.players
        .map(
          (player) => player.id == playerId
              ? player.copyWith(isReady: !player.isReady)
              : player,
        )
        .toList();
    final updated = room.copyWith(
      players: players,
      status: players.length >= 2 && players.every((player) => player.isReady)
          ? 'ready'
          : 'waiting',
    );
    _rooms[room.roomCode] = updated;
    return updated;
  }

  Future<RoomModel> addBot(RoomModel room) async {
    if (!room.allowBots) throw StateError('Bots are disabled for this room.');
    if (room.isFull) throw StateError('This room is already full.');
    final seat = _firstEmptySeat(room);
    final bot = RoomPlayerModel(
      id: 'bot_${room.roomCode}_$seat',
      username: 'Card Bot ${seat + 1}',
      avatar: 'BOT',
      isHost: false,
      isReady: true,
      isBot: true,
      seatIndex: seat,
      connectionStatus: 'connected',
    );
    final players = [...room.players, bot];
    final updated = room.copyWith(
      players: players,
      status: players.length >= 2 && players.every((player) => player.isReady)
          ? 'ready'
          : 'waiting',
    );
    _rooms[room.roomCode] = updated;
    return updated;
  }

  Future<RoomModel> removePlayer(RoomModel room, String playerId) async {
    final updated = room.copyWith(
      players: room.players.where((player) => player.id != playerId).toList(),
      status: 'waiting',
    );
    _rooms[room.roomCode] = updated;
    return updated;
  }

  Future<List<RoomModel>> getPublicRooms() async {
    if (_rooms.values.where((room) => !room.isPrivate).length < 5) {
      for (final room in _buildPublicRooms()) {
        _rooms.putIfAbsent(room.roomCode, () => room);
      }
    }
    return _rooms.values.where((room) => !room.isPrivate).toList();
  }

  String _uniqueCode() {
    var code = _roomCodeService.generateRoomCode();
    while (_rooms.containsKey(code)) {
      code = _roomCodeService.generateRoomCode();
    }
    return code;
  }

  RoomModel _joinedRoom(String code) => RoomModel(
    roomCode: code,
    roomName: 'Ali\'s Private Table',
    gameType: 'war',
    gameName: 'War',
    roomType: 'private',
    maxPlayers: 4,
    players: const [
      RoomPlayerModel(
        id: 'friend_ali',
        username: 'Ali',
        avatar: 'A',
        isHost: true,
        isReady: true,
        isBot: false,
        seatIndex: 0,
        connectionStatus: 'connected',
      ),
    ],
    allowBots: true,
    allowChat: true,
    isPrivate: true,
    status: 'waiting',
    createdAt: DateTime.now(),
    settings: const {
      'turnTimeSeconds': 30,
      'difficulty': 'Normal',
      'allowSpectators': false,
      'autoStart': false,
    },
  );

  List<RoomModel> _buildPublicRooms() {
    const games = [
      ('high_card', 'High Card'),
      ('war', 'War'),
      ('blackjack', 'Blackjack'),
      ('war', 'War'),
      ('high_card', 'High Card'),
      ('blackjack', 'Blackjack'),
    ];
    return List.generate(games.length, (index) {
      final game = games[index];
      final maxPlayers = index.isEven ? 4 : 3;
      final playerCount = index % 3 + 1;
      return RoomModel(
        roomCode: 'CV${(1200 + index).toString()}',
        roomName: [
          'Golden Table',
          'Weekend Warriors',
          'Blackjack Lounge',
          'Quick Match',
          'Classic Cards',
          'Dealer\'s Choice',
        ][index],
        gameType: game.$1,
        gameName: game.$2,
        roomType: 'public',
        maxPlayers: maxPlayers,
        players: List.generate(
          playerCount,
          (seat) => RoomPlayerModel(
            id: 'public_${index}_$seat',
            username: seat == 0
                ? ['Ali', 'Sara', 'Meera'][index % 3]
                : 'Player ${seat + 1}',
            avatar: 'P${seat + 1}',
            isHost: seat == 0,
            isReady: seat != playerCount - 1,
            isBot: false,
            seatIndex: seat,
            connectionStatus: 'connected',
          ),
        ),
        allowBots: index != 2,
        allowChat: true,
        isPrivate: false,
        status: 'waiting',
        createdAt: DateTime.now().subtract(Duration(minutes: index * 4)),
        settings: const {
          'turnTimeSeconds': 30,
          'difficulty': 'Casual',
          'allowSpectators': true,
          'autoStart': false,
        },
      );
    });
  }

  int _firstEmptySeat(RoomModel room) {
    final occupied = room.players.map((player) => player.seatIndex).toSet();
    for (var index = 0; index < room.maxPlayers; index++) {
      if (!occupied.contains(index)) return index;
    }
    return room.maxPlayers;
  }
}
