class CosmeticItemModel {
  const CosmeticItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isUnlocked,
    required this.isEquipped,
  });

  factory CosmeticItemModel.fromJson(Map<String, dynamic> json) =>
      CosmeticItemModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Theme',
        type: json['type'] as String? ?? 'cardTheme',
        price: (json['price'] as num?)?.toInt() ?? 0,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isEquipped: json['isEquipped'] as bool? ?? false,
      );

  final String id;
  final String name;
  final String type;
  final int price;
  final bool isUnlocked;
  final bool isEquipped;
}
