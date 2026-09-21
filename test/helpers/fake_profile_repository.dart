import 'dart:async';

import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({UserProfile? initialProfile})
    : profile = initialProfile;

  final _changes = StreamController<UserProfile?>.broadcast();
  UserProfile? profile;

  @override
  Future<UserProfile?> loadCurrentProfile() async => profile;

  @override
  Stream<UserProfile?> watchCurrentProfile() => _changes.stream;

  @override
  Future<UserProfile> createProfile({
    required String username,
    required String displayName,
  }) async {
    if (username == 'taken') throw const DuplicateUsernameFailure();
    profile = sampleProfile(username: username, displayName: displayName);
    _changes.add(profile);
    return profile!;
  }

  @override
  Future<UserProfile> updateProfile({
    required String username,
    required String displayName,
  }) async {
    if (username == 'taken') throw const DuplicateUsernameFailure();
    final current = profile!;
    profile = UserProfile(
      id: current.id,
      email: current.email,
      username: username,
      displayName: displayName,
      role: current.role,
      createdAt: current.createdAt,
      updatedAt: DateTime.utc(2026, 9, 16, 1),
    );
    _changes.add(profile);
    return profile!;
  }

  Future<void> dispose() => _changes.close();
}

UserProfile sampleProfile({
  String username = 'alexplays',
  String displayName = 'Alex Rivera',
  UserRole role = UserRole.player,
}) {
  return UserProfile(
    id: 'user-1',
    email: 'player@example.com',
    username: username,
    displayName: displayName,
    role: role,
    createdAt: DateTime.utc(2026, 9, 16),
    updatedAt: DateTime.utc(2026, 9, 16),
  );
}
