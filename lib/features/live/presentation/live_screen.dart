import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

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
                  eyebrow: 'Match center',
                  title: 'Live from the arena.',
                  description: 'Follow the action in real time with this static match-day preview.',
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Chip(
                          avatar: Icon(Icons.sensors_rounded, color: colors.onErrorContainer, size: 18),
                          label: const Text('LIVE · MAP 2'),
                          backgroundColor: colors.errorContainer,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TeamScore(name: 'Team Aurora', score: '10'),
                            Text('VS', style: theme.textTheme.labelLarge?.copyWith(color: colors.onSurfaceVariant)),
                            _TeamScore(name: 'Northstar', score: '8', alignEnd: true),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text('Manila Open Series · Semifinal', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('UP NEXT', style: theme.textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                const _UpcomingMatch(time: '7:30 PM', teams: 'Blue Comets vs. Arc Light'),
                const _UpcomingMatch(time: '8:15 PM', teams: 'Solstice vs. Kingsmen'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamScore extends StatelessWidget {
  const _TeamScore({required this.name, required this.score, this.alignEnd = false});

  final String name;
  final String score;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(name, style: Theme.of(context).textTheme.titleMedium),
        Text(score, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _UpcomingMatch extends StatelessWidget {
  const _UpcomingMatch({required this.time, required this.teams});

  final String time;
  final String teams;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.schedule_rounded, color: Theme.of(context).colorScheme.primary),
        title: Text(teams),
        trailing: Text(time, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
