import 'package:tourna/features/profile/domain/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> loadCurrentProfile();

  Stream<UserProfile?> watchCurrentProfile();

  Future<UserProfile> createProfile({
    required String username,
    required String displayName,
  });

  Future<UserProfile> updateProfile({
    required String username,
    required String displayName,
  });
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class DuplicateUsernameFailure extends ProfileFailure {
  const DuplicateUsernameFailure()
    : super('That username is already taken. Try another one.');
}
