import 'package:tourna/features/team/domain/team.dart';

abstract class TeamRepository {
  Future<Team?> loadCurrentTeam();

  Future<Team> createTeam({required String name});

  Future<Team> joinTeam({required String joinCode});

  Future<void> leaveTeam();
}

class TeamFailure implements Exception {
  const TeamFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
