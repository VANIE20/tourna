import 'package:tourna/features/team/domain/team.dart';
import 'package:tourna/features/team/domain/team_repository.dart';

class FakeTeamRepository implements TeamRepository {
  FakeTeamRepository({this.team});

  Team? team;

  @override
  Future<Team?> loadCurrentTeam() async => team;

  @override
  Future<Team> createTeam({required String name}) async {
    team = sampleTeam(name: name);
    return team!;
  }

  @override
  Future<Team> joinTeam({required String joinCode}) async {
    if (joinCode.toUpperCase() != 'ABCDEF1234') {
      throw const TeamFailure('That team code is invalid or has expired.');
    }
    team = sampleTeam(currentUserRole: TeamMemberRole.player);
    return team!;
  }

  @override
  Future<void> leaveTeam() async => team = null;
}

Team sampleTeam({
  String name = 'Team Aurora',
  TeamMemberRole currentUserRole = TeamMemberRole.captain,
}) {
  final isCaptain = currentUserRole == TeamMemberRole.captain;
  return Team(
    id: 'team-1',
    name: name,
    captainId: isCaptain ? 'user-1' : 'user-2',
    joinCode: 'ABCDEF1234',
    createdAt: DateTime.utc(2026, 9, 16),
    currentUserRole: currentUserRole,
    members: [
      if (!isCaptain)
        TeamMember(
          userId: 'user-2',
          username: 'minamoves',
          displayName: 'Mina Santos',
          role: TeamMemberRole.captain,
          joinedAt: DateTime.utc(2026, 9, 15),
        ),
      TeamMember(
        userId: 'user-1',
        username: 'alexplays',
        displayName: 'Alex Rivera',
        role: currentUserRole,
        joinedAt: DateTime.utc(2026, 9, 16),
      ),
    ],
  );
}
