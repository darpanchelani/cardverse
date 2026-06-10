import 'dart:math';

class RoomCodeService {
  RoomCodeService({Random? random}) : _random = random ?? Random();

  static const _characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random _random;

  String generateRoomCode() => List.generate(
    6,
    (_) => _characters[_random.nextInt(_characters.length)],
  ).join();

  bool isValidRoomCode(String code) =>
      RegExp(r'^[A-Z0-9]{6}$').hasMatch(code.trim().toUpperCase());
}
