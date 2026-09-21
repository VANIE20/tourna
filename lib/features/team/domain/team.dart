class Team {
  const Team({
    required this.id,
    required this.name,
    required this.captainId,
    required this.joinCode,
    required this.createdAt,
    required this.currentUserRole,
    required this.members,
  });

  final String id;
  final String name;
  final String captainId;
  final String joinCode;
  final DateTime createdAt;
  final TeamMemberRole currentUserRole;
  final List<TeamMember> members;

  TeamMember? get captain {
    for (final member in members) {
      if (member.userId == captainId) return member;
    }
    return null;
  }
}

enum TeamMemberRole {
  captain,
  player;

  static TeamMemberRole fromValue(String? value) {
    return value == captain.name ? captain : player;
  }
}

class TeamMember {
  const TeamMember({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.role,
    required this.joinedAt,
  });

  final String userId;
  final String username;
  final String displayName;
  final TeamMemberRole role;
  final DateTime joinedAt;

  String get initials {
    final words = displayName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}
