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

  factory PlayingCardModel.fromJson(Map<String, dynamic> json) {
    return PlayingCardModel(
      suit: json['suit'] as String? ?? '',
      rank: json['rank'] as String? ?? '',
      value: (json['value'] as num?)?.toInt() ?? 0,
      displayName: json['displayName'] as String? ?? '',
      suitSymbol: json['suitSymbol'] as String? ?? '',
      colorType: json['colorType'] == 'red'
          ? CardColorType.red
          : CardColorType.black,
    );
  }

  Map<String, dynamic> toJson() => {
    'suit': suit,
    'rank': rank,
    'value': value,
    'displayName': displayName,
    'suitSymbol': suitSymbol,
    'colorType': colorType.name,
  };

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
