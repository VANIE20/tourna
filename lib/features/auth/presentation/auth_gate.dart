import 'package:flutter/material.dart';
import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/auth/domain/auth_session.dart';
import 'package:tourna/features/auth/presentation/auth_screen.dart';
import 'package:tourna/features/navigation/presentation/main_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({required this.repository, super.key});

  final AuthRepository repository;

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
            return MainShell(onSignOut: widget.repository.signOut);
          },
        );
      },
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
