class LocalAccountModel {
  const LocalAccountModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  factory LocalAccountModel.fromJson(Map<String, dynamic> json) {
    return LocalAccountModel(
      id:
          json['id'] as String? ??
          (json['email'] as String? ?? '').trim().toLowerCase(),
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'username': username,
    'email': email,
    'passwordHash': passwordHash,
    'createdAt': createdAt.toIso8601String(),
  };
}
