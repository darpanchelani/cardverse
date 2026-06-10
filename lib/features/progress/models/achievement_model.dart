class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.rewardCoins,
    required this.rewardXp,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'star',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: DateTime.tryParse(json['unlockedAt'] as String? ?? ''),
      rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 0,
      rewardXp: (json['rewardXp'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int rewardCoins;
  final int rewardXp;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'rewardCoins': rewardCoins,
    'rewardXp': rewardXp,
  };

  AchievementModel copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rewardCoins: rewardCoins,
      rewardXp: rewardXp,
    );
  }
}
