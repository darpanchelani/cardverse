enum CardColorType { red, black }

class PlayingCardModel {
  const PlayingCardModel({
    required this.suit,
    required this.rank,
    required this.value,
    required this.displayName,
    required this.suitSymbol,
    required this.colorType,
  });

  final String suit;
  final String rank;
  final int value;
  final String displayName;
  final String suitSymbol;
  final CardColorType colorType;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayingCardModel &&
            suit == other.suit &&
            rank == other.rank &&
            value == other.value;
  }

  @override
  int get hashCode => Object.hash(suit, rank, value);
}
