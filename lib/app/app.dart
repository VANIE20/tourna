import 'package:flutter/material.dart';
import 'package:tourna/app/theme/app_theme.dart';
import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/auth/presentation/auth_gate.dart';

class TournaApp extends StatelessWidget {
  const TournaApp({this.authRepository, this.configurationError, super.key});

  final AuthRepository? authRepository;
  final String? configurationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOURNA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: authRepository == null
          ? _ConfigurationScreen(message: configurationError)
          : AuthGate(repository: authRepository!),
    );
  }
}

class _ConfigurationScreen extends StatelessWidget {
  const _ConfigurationScreen({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_suggest_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication setup required',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message ?? 'Add the Supabase runtime configuration to continue.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
