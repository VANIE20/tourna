import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourna/app/app.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('shows the TOURNA home experience', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Every match starts with a challenge.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
    expect(find.byKey(const Key('explore-tournaments')), findsOneWidget);
    await repository.dispose();
  });

  testWidgets('switches between all main destinations', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    await tester.pumpWidget(TournaApp(authRepository: repository));
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
  });

  testWidgets('opens tournaments from the home call to action', (tester) async {
    final repository = FakeAuthRepository(initialSession: signedInSession);
    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('explore-tournaments')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next bracket.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
    await repository.dispose();
  });

  testWidgets('uses an adaptive navigation rail on wide layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;

    final repository = FakeAuthRepository(initialSession: signedInSession);
    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    await repository.dispose();
  });
}
