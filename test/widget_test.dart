import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourna/app/app.dart';

void main() {
  testWidgets('shows the TOURNA home experience', (tester) async {
    await tester.pumpWidget(const TournaApp());

    expect(find.text('Every match starts with a challenge.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
    expect(find.byKey(const Key('explore-tournaments')), findsOneWidget);
  });

  testWidgets('switches between all main destinations', (tester) async {
    await tester.pumpWidget(const TournaApp());

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
  });

  testWidgets('opens tournaments from the home call to action', (tester) async {
    await tester.pumpWidget(const TournaApp());

    await tester.tap(find.byKey(const Key('explore-tournaments')));
    await tester.pumpAndSettle();

    expect(find.text('Find your next bracket.'), findsOneWidget);
    expect(find.text('Manila Open Series'), findsOneWidget);
  });

  testWidgets('uses an adaptive navigation rail on wide layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const TournaApp());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
