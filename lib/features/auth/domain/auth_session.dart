class AuthSession {
  const AuthSession({required this.user});

  final AuthUser user;
}

class AuthUser {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String? email;
}
