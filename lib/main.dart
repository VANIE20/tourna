import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tourna/app/app.dart';
import 'package:tourna/core/config/supabase_config.dart';
import 'package:tourna/features/auth/data/supabase_auth_repository.dart';
import 'package:tourna/features/auth/domain/auth_repository.dart';
import 'package:tourna/features/profile/data/supabase_profile_repository.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/team/data/supabase_team_repository.dart';
import 'package:tourna/features/team/domain/team_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = SupabaseConfig.fromEnvironment();
  AuthRepository? authRepository;
  ProfileRepository? profileRepository;
  TeamRepository? teamRepository;
  String? configurationError;

  if (!config.isConfigured) {
    configurationError =
        'Add SUPABASE_URL and SUPABASE_ANON_KEY as dart-defines to continue.';
  } else if (!config.hasValidUrl) {
    configurationError = 'SUPABASE_URL must be a valid HTTP or HTTPS URL.';
  } else {
    try {
      final supabase = await Supabase.initialize(
        url: config.url,
        publishableKey: config.anonKey,
      );
      authRepository = SupabaseAuthRepository(supabase.client);
      profileRepository = SupabaseProfileRepository(supabase.client);
      teamRepository = SupabaseTeamRepository(supabase.client);
    } catch (_) {
      configurationError =
          'TOURNA could not initialize authentication. Please try again.';
    }
  }

  runApp(
    TournaApp(
      authRepository: authRepository,
      profileRepository: profileRepository,
      teamRepository: teamRepository,
      configurationError: configurationError,
    ),
  );
}
