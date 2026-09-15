import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.onSignOut, super.key});

  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  eyebrow: 'Player profile',
                  title: 'Alex Rivera',
                  description: 'A local player profile for your Phase 1 TOURNA experience.',
                ),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(24),
                    leading: CircleAvatar(
                      radius: 34,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Text(
                        'AR',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      '@alexplays',
                      style: theme.textTheme.titleLarge,
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Manila, Philippines\nVALORANT · Mobile Legends',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'COMPETITIVE SNAPSHOT',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                      child: _StatCard(value: '14', label: 'Matches'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(value: '9', label: 'Wins'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(value: '64%', label: 'Win rate'),
                    ),
                  ],
                ),
                if (onSignOut != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('sign-out'),
                      onPressed: () async {
                        try {
                          await onSignOut!();
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not sign out. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
