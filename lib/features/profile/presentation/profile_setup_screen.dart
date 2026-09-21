import 'package:flutter/material.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';
import 'package:tourna/features/profile/presentation/profile_form.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({
    required this.repository,
    required this.onProfileCreated,
    super.key,
  });

  final ProfileRepository repository;
  final ValueChanged<UserProfile> onProfileCreated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 700 ? 48.0 : 24.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 32, horizontal, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.sports_esports_rounded,
                            color: colors.onPrimaryContainer,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Claim your player identity',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose how you’ll appear to teammates. You can update these details later.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: ProfileForm(
                            submitLabel: 'Enter TOURNA',
                            onSubmit: (username, displayName) async {
                              final profile = await repository.createProfile(
                                username: username,
                                displayName: displayName,
                              );
                              onProfileCreated(profile);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
