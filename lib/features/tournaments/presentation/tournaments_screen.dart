import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TournamentPage();
  }
}

class _TournamentPage extends StatelessWidget {
  const _TournamentPage();

  static const _events = [
    ('VALORANT', 'Manila Open Series', 'Sep 21 · 6:00 PM', '12 of 16 teams'),
    ('MOBILE LEGENDS', 'Campus Clash', 'Sep 28 · 1:00 PM', '24 of 32 teams'),
    ('BASKETBALL', 'City Courts 3x3', 'Oct 05 · 9:00 AM', '8 of 12 teams'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  eyebrow: 'Competition hub',
                  title: 'Find your next bracket.',
                  description:
                      'Choose an event, check the format, and bring your squad to the arena.',
                ),
                const SizedBox(height: 32),
                for (final event in _events)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      title: Text(event.$2, style: theme.textTheme.titleLarge),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${event.$1} · ${event.$3}\n${event.$4}'),
                      ),
                      trailing: Chip(
                        label: const Text('Open'),
                        backgroundColor: colors.primaryContainer,
                      ),
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
