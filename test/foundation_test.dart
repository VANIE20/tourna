import 'package:flutter_test/flutter_test.dart';
import 'package:tourna/core/config/supabase_config.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';

void main() {
  group('SupabaseConfig', () {
    test('is unconfigured when either value is missing', () {
      expect(
        const SupabaseConfig(url: '', anonKey: 'public-key').isConfigured,
        false,
      );
      expect(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: '',
        ).isConfigured,
        false,
      );
    });

    test('accepts configured HTTP and HTTPS endpoints', () {
      expect(
        const SupabaseConfig(
          url: 'https://example.supabase.co',
          anonKey: 'public-key',
        ).hasValidUrl,
        true,
      );
      expect(
        const SupabaseConfig(
          url: 'http://localhost:54321',
          anonKey: 'public-key',
        ).hasValidUrl,
        true,
      );
    });
  });

  group('UserRole', () {
    test('supports every Phase 2 role', () {
      expect(UserRole.values, [
        UserRole.guest,
        UserRole.player,
        UserRole.captain,
        UserRole.organizer,
        UserRole.admin,
      ]);
    });

    test('falls back safely for missing and unknown roles', () {
      expect(UserRole.fromValue('CAPTAIN'), UserRole.captain);
      expect(UserRole.fromValue('unknown'), UserRole.guest);
      expect(UserRole.fromValue(null), UserRole.guest);
    });
  });
}
