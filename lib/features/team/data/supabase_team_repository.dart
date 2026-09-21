import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourna/features/team/domain/team.dart';
import 'package:tourna/features/team/domain/team_repository.dart';

class SupabaseTeamRepository implements TeamRepository {
  SupabaseTeamRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Team?> loadCurrentTeam() async {
    final userId = _requireUserId();
    try {
      final membership = await _client
          .from('tourna_team_members')
          .select(
            'member_role, tourna_teams!inner(id, name, captain_id, join_code, created_at)',
          )
          .eq('user_id', userId)
          .maybeSingle();
      if (membership == null) return null;

      final teamRow = membership['tourna_teams'] as Map<String, dynamic>;
      return await _loadTeam(
        teamRow,
        TeamMemberRole.fromValue(membership['member_role'] as String?),
      );
    } on PostgrestException catch (error) {
      throw TeamFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<Team> createTeam({required String name}) async {
    _requireUserId();
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _client.rpc(
          'tourna_create_team',
          params: {'p_name': name.trim()},
        );
        final team = await loadCurrentTeam();
        if (team != null) return team;
      } on PostgrestException catch (error) {
        if (error.code == '23505' && attempt < 2) continue;
        throw TeamFailure(_friendlyMessage(error));
      }
    }
    throw const TeamFailure('Could not create a unique team invite code.');
  }

  @override
  Future<Team> joinTeam({required String joinCode}) async {
    _requireUserId();
    try {
      await _client.rpc(
        'tourna_join_team',
        params: {'p_join_code': joinCode.trim().toUpperCase()},
      );
      final team = await loadCurrentTeam();
      if (team != null) return team;
      throw const TeamFailure('The team could not be loaded after joining.');
    } on PostgrestException catch (error) {
      throw TeamFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<void> leaveTeam() async {
    _requireUserId();
    try {
      await _client.rpc('tourna_leave_team');
    } on PostgrestException catch (error) {
      throw TeamFailure(_friendlyMessage(error));
    }
  }

  Future<Team> _loadTeam(
    Map<String, dynamic> teamRow,
    TeamMemberRole currentUserRole,
  ) async {
    final rows = await _client
        .from('tourna_team_members')
        .select(
          'user_id, member_role, joined_at, tourna_profiles!inner(username, display_name)',
        )
        .eq('team_id', teamRow['id'] as String)
        .order('joined_at');

    final members = rows
        .map((row) {
          final profile = row['tourna_profiles'] as Map<String, dynamic>;
          return TeamMember(
            userId: row['user_id'] as String,
            username: profile['username'] as String,
            displayName: profile['display_name'] as String,
            role: TeamMemberRole.fromValue(row['member_role'] as String?),
            joinedAt: DateTime.parse(row['joined_at'] as String),
          );
        })
        .toList(growable: false);

    return Team(
      id: teamRow['id'] as String,
      name: teamRow['name'] as String,
      captainId: teamRow['captain_id'] as String,
      joinCode: teamRow['join_code'] as String,
      createdAt: DateTime.parse(teamRow['created_at'] as String),
      currentUserRole: currentUserRole,
      members: members,
    );
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const TeamFailure('Sign in to access your team.');
    return userId;
  }

  static String _friendlyMessage(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (message.contains('already belongs')) {
      return 'You already belong to a team.';
    }
    if (message.contains('invite code')) {
      return 'That team code is invalid or has expired.';
    }
    if (message.contains('captain')) {
      return 'Captains must transfer ownership or be the last member before leaving.';
    }
    if (error.code == '42501') {
      return 'You do not have permission to change this team.';
    }
    return 'We could not update your team. Please try again.';
  }
}
