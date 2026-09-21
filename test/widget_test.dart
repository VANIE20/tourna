import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourna/app/app.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_profile_repository.dart';
import 'helpers/fake_team_repository.dart';

void main() {
  testWidgets('shows the TOURNA home experience', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    await tester.pumpWidget(
      TournaApp(
        authRepository: repository,
        profileRepository: profiles,
        teamRepository: FakeTeamRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Every match starts with a challenge.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
    expect(find.byKey(const Key('explore-tournaments')), findsOneWidget);
    await repository.dispose();
    await profiles.dispose();
  });

  testWidgets('switches between all main destinations', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    await tester.pumpWidget(
      TournaApp(
        authRepository: repository,
        profileRepository: profiles,
        teamRepository: FakeTeamRepository(team: sampleTeam()),
      ),
    );
    await tester.pumpAndSettle();

    for (final destination in const [
      ('Tournaments', 'Find your next bracket.'),
      ('Team', 'Team Aurora'),
      ('Live', 'Live from the arena.'),
      ('Profile', 'Alex Rivera'),
    ]) {
      await tester.tap(find.text(destination.$1).last);
      await tester.pumpAndSettle();
      expect(find.text(destination.$2), findsOneWidget);
    }
    await repository.dispose();
    await profiles.dispose();
  });

  testWidgets('opens tournaments from the home call to action', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    await tester.pumpWidget(
      TournaApp(
        authRepository: repository,
        profileRepository: profiles,
        teamRepository: FakeTeamRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('explore-tournaments')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next bracket.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
    await repository.dispose();
    await profiles.dispose();
  });

  testWidgets('uses an adaptive navigation rail on wide layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;

    final repository = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    await tester.pumpWidget(
      TournaApp(
        authRepository: repository,
        profileRepository: profiles,
        teamRepository: FakeTeamRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await repository.dispose();
    await profiles.dispose();
  });

  testWidgets('creates a team from the empty team state', (tester) async {
    final auth = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    final teams = FakeTeamRepository();
    await tester.pumpWidget(
      TournaApp(
        authRepository: auth,
        profileRepository: profiles,
        teamRepository: teams,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Team').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('create-team')), findsOneWidget);
    await tester.tap(find.byKey(const Key('create-team')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('team-dialog-input')),
      'Night Owls',
    );
    await tester.tap(find.byKey(const Key('team-dialog-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Night Owls'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.byKey(const Key('team-join-code')), findsOneWidget);
    await auth.dispose();
    await profiles.dispose();
  });

  testWidgets('joins a team with a valid code', (tester) async {
    final auth = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(initialProfile: sampleProfile());
    final teams = FakeTeamRepository();
    await tester.pumpWidget(
      TournaApp(
        authRepository: auth,
        profileRepository: profiles,
        teamRepository: teams,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Team').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('join-team')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('team-dialog-input')),
      'abcdef1234',
    );
    await tester.tap(find.byKey(const Key('team-dialog-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Team Aurora'), findsOneWidget);
    expect(find.text('Mina Santos'), findsOneWidget);
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('Player'), findsOneWidget);
    expect(find.byKey(const Key('leave-team')), findsOneWidget);
    await auth.dispose();
    await profiles.dispose();
  });

  testWidgets('edits profile identity without changing the account role', (
    tester,
  ) async {
    final auth = FakeAuthRepository(initialSession: signedInSession);
    final profiles = FakeProfileRepository(
      initialProfile: sampleProfile(role: UserRole.organizer),
    );
    await tester.pumpWidget(
      TournaApp(
        authRepository: auth,
        profileRepository: profiles,
        teamRepository: FakeTeamRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-profile')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('profile-username')),
      'alex_updated',
    );
    await tester.enterText(
      find.byKey(const Key('profile-display-name')),
      'Alex Updated',
    );
    await tester.tap(find.byKey(const Key('profile-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Alex Updated'), findsOneWidget);
    expect(find.text('@alex_updated'), findsOneWidget);
    expect(find.text('Organizer account'), findsOneWidget);
    expect(profiles.profile?.role, UserRole.organizer);
    await auth.dispose();
    await profiles.dispose();
  });
}
