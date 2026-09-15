import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourna/app/app.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('routes an unauthenticated user to sign in', (tester) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(find.text('Every match starts with a challenge.'), findsNothing);
    await repository.dispose();
  });

  testWidgets('reacts to sign-in and sign-out state changes', (tester) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();

    repository.emit(signedInSession);
    await tester.pumpAndSettle();
    expect(find.text('Every match starts with a challenge.'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    await repository.dispose();
  });

  testWidgets('allows an existing account with a shorter password to sign in', (
    tester,
  ) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login-email')),
      'player@example.com',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'secret');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Every match starts with a challenge.'), findsOneWidget);
    await repository.dispose();
  });

  testWidgets('validates sign-up fields before submitting', (tester) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New to TOURNA? Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    await repository.dispose();
  });

  testWidgets('requests a password reset for a valid email', (tester) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(TournaApp(authRepository: repository));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login-email')),
      'player@example.com',
    );
    await tester.tap(find.byKey(const Key('forgot-password')));
    await tester.pumpAndSettle();

    expect(repository.passwordResetEmail, 'player@example.com');
    expect(
      find.text('Check your email for a password reset link.'),
      findsOneWidget,
    );
    await repository.dispose();
  });

  testWidgets('shows a safe state when configuration is missing', (
    tester,
  ) async {
    await tester.pumpWidget(const TournaApp());

    expect(find.text('Authentication setup required'), findsOneWidget);
  });
}
