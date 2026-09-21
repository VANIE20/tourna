import 'package:flutter/material.dart';
import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/auth/domain/auth_session.dart';
import 'package:tourna/features/auth/presentation/auth_screen.dart';
import 'package:tourna/features/navigation/presentation/main_shell.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';
import 'package:tourna/features/profile/presentation/profile_setup_screen.dart';
import 'package:tourna/features/team/domain/team_repository.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    required this.repository,
    required this.profileRepository,
    required this.teamRepository,
    super.key,
  });

  final AuthRepository repository;
  final ProfileRepository profileRepository;
  final TeamRepository teamRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<AuthSession?> _restoredSession;

  @override
  void initState() {
    super.initState();
    _restoredSession = widget.repository.restoreSession();
  }

  @override
  void didUpdateWidget(AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      _restoredSession = widget.repository.restoreSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSession?>(
      future: _restoredSession,
      builder: (context, restoration) {
        if (restoration.connectionState != ConnectionState.done) {
          return const _AuthLoadingScreen();
        }
        if (restoration.hasError) {
          return _AuthErrorScreen(
            onRetry: () {
              setState(() {
                _restoredSession = widget.repository.restoreSession();
              });
            },
          );
        }
        return StreamBuilder<AuthSession?>(
          stream: widget.repository.authStateChanges,
          initialData: restoration.data,
          builder: (context, authState) {
            if (authState.hasError) {
              return _AuthErrorScreen(
                onRetry: () {
                  setState(() {
                    _restoredSession = widget.repository.restoreSession();
                  });
                },
              );
            }
            if (authState.data == null) {
              return AuthScreen(repository: widget.repository);
            }
            return _ProfileGate(
              key: ValueKey(authState.data!.user.id),
              repository: widget.profileRepository,
              teamRepository: widget.teamRepository,
              onSignOut: widget.repository.signOut,
            );
          },
        );
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate({
    required this.repository,
    required this.teamRepository,
    required this.onSignOut,
    super.key,
  });

  final ProfileRepository repository;
  final TeamRepository teamRepository;
  final Future<void> Function() onSignOut;

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  late Future<UserProfile?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.repository.loadCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AuthLoadingScreen();
        }
        if (snapshot.hasError) {
          return _ProfileLoadError(
            onRetry: () => setState(() {
              _profile = widget.repository.loadCurrentProfile();
            }),
            onSignOut: widget.onSignOut,
          );
        }
        final profile = snapshot.data;
        if (profile == null) {
          return ProfileSetupScreen(
            repository: widget.repository,
            onProfileCreated: (created) {
              setState(() => _profile = Future.value(created));
            },
          );
        }
        return MainShell(
          profile: profile,
          profileRepository: widget.repository,
          teamRepository: widget.teamRepository,
          onSignOut: widget.onSignOut,
        );
      },
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.onRetry, required this.onSignOut});

  final VoidCallback onRetry;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Unable to load your profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your connection, then try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                TextButton(onPressed: onSignOut, child: const Text('Sign out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(semanticsLabel: 'Loading')),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Unable to restore your session',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your connection, then try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
