import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfile?> loadCurrentProfile() async {
    final user = _requireUser();
    try {
      final row = await _client
          .from('tourna_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return row == null ? null : _fromRow(row, email: user.email);
    } on PostgrestException catch (error) {
      throw ProfileFailure(_friendlyMessage(error));
    }
  }

  @override
  Stream<UserProfile?> watchCurrentProfile() {
    final user = _requireUser();
    return _client
        .from('tourna_profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map(
          (rows) =>
              rows.isEmpty ? null : _fromRow(rows.single, email: user.email),
        );
  }

  @override
  Future<UserProfile> createProfile({
    required String username,
    required String displayName,
  }) async {
    final user = _requireUser();
    try {
      final row = await _client
          .from('tourna_profiles')
          .insert({
            'id': user.id,
            'username': username.trim().toLowerCase(),
            'display_name': displayName.trim(),
          })
          .select()
          .single();
      return _fromRow(row, email: user.email);
    } on PostgrestException catch (error) {
      if (error.code == '23505') throw const DuplicateUsernameFailure();
      throw ProfileFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String username,
    required String displayName,
  }) async {
    final user = _requireUser();
    try {
      final row = await _client
          .from('tourna_profiles')
          .update({
            'username': username.trim().toLowerCase(),
            'display_name': displayName.trim(),
          })
          .eq('id', user.id)
          .select()
          .single();
      return _fromRow(row, email: user.email);
    } on PostgrestException catch (error) {
      if (error.code == '23505') throw const DuplicateUsernameFailure();
      throw ProfileFailure(_friendlyMessage(error));
    }
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ProfileFailure('Sign in to access your profile.');
    }
    return user;
  }

  static UserProfile _fromRow(Map<String, dynamic> row, {String? email}) {
    return UserProfile(
      id: row['id'] as String,
      email: email,
      username: row['username'] as String,
      displayName: row['display_name'] as String,
      role: UserRole.fromValue(row['role'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  static String _friendlyMessage(PostgrestException error) {
    if (error.code == '42501') {
      return 'You do not have permission to change this profile.';
    }
    return 'We could not load your player profile. Please try again.';
  }
}
