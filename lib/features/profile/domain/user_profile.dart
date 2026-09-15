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
    required this.email,
    required this.role,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
  final UserRole role;
}
