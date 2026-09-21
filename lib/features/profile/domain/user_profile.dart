enum UserRole {
  guest,
  player,
  captain,
  organizer,
  admin;

  static UserRole fromValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value?.trim().toLowerCase(),
      orElse: () => UserRole.guest,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.email,
  });

  final String id;
  final String? email;
  final String username;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final words = displayName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}
