import 'dart:async';

import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/auth/domain/auth_session.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthSession? initialSession}) : _session = initialSession;

  final _changes = StreamController<AuthSession?>.broadcast();
  AuthSession? _session;

  @override
  AuthSession? get currentSession => _session;

  @override
  Stream<AuthSession?> get authStateChanges => _changes.stream;

  @override
  Future<AuthSession?> restoreSession() async => _session;

  @override
  Future<AuthSession?> signIn({
    required String email,
    required String password,
  }) async {
    final session = AuthSession(
      user: AuthUser(id: 'user-1', email: email),
    );
    emit(session);
    return session;
  }

  @override
  Future<AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    final session = AuthSession(
      user: AuthUser(id: 'user-1', email: email),
    );
    emit(session);
    return session;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    passwordResetEmail = email;
  }

  String? passwordResetEmail;

  @override
  Future<void> signOut() async => emit(null);

  void emit(AuthSession? session) {
    _session = session;
    _changes.add(session);
  }

  Future<void> dispose() => _changes.close();
}

const signedInSession = AuthSession(
  user: AuthUser(id: 'user-1', email: 'player@example.com'),
);
