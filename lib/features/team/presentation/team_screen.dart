import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const players = [
      ('Alex Rivera', 'Captain · Controller', 'AR'),
      ('Mika Santos', 'Duelist', 'MS'),
      ('Jules Tan', 'Initiator', 'JT'),
      ('Rin Dela Cruz', 'Sentinel', 'RD'),
      ('Noah Reyes', 'Flex', 'NR'),
    ];
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
                  eyebrow: 'Your squad',
                  title: 'Team Aurora',
                  description: 'Your local roster is ready for the Manila Open Series.',
                ),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: const Icon(Icons.bolt_rounded),
                    ),
                    title: Text('5 active players', style: theme.textTheme.titleLarge),
                    subtitle: const Text('VALORANT · Philippines'),
                  ),
                ),
                const SizedBox(height: 32),
                Text('ROSTER', style: theme.textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                for (final player in players)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(player.$3)),
                      title: Text(player.$1),
                      subtitle: Text(player.$2),
                      trailing: Icon(Icons.verified_rounded, color: colors.primary, semanticLabel: 'Active player'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
