import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/auth/domain/auth_session.dart' as domain;

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  domain.AuthSession? get currentSession =>
      _toDomainSession(_client.auth.currentSession);

  @override
  Stream<domain.AuthSession?> get authStateChanges => _client
      .auth
      .onAuthStateChange
      .map((event) => _toDomainSession(event.session));

  @override
  Future<domain.AuthSession?> restoreSession() async => currentSession;

  @override
  Future<domain.AuthSession?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return _toDomainSession(response.session);
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<domain.AuthSession?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      return _toDomainSession(response.session);
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    }
  }

  static domain.AuthSession? _toDomainSession(Session? session) {
    if (session == null) return null;
    return domain.AuthSession(
      user: domain.AuthUser(id: session.user.id, email: session.user.email),
    );
  }

  static String _friendlyMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login') ||
        message.contains('invalid credentials')) {
      return 'The email or password is incorrect.';
    }
    if (message.contains('email not confirmed')) {
      return 'Confirm your email before signing in.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'An account already exists for this email.';
    }
    if (message.contains('password')) {
      return 'Choose a stronger password with at least 8 characters.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'We could not complete that request. Please try again.';
  }
}
