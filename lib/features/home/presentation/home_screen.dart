import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onExploreTournaments, super.key});

  final VoidCallback onExploreTournaments;

  static const _tournaments = <_TournamentPreview>[
    _TournamentPreview(
      game: 'VALORANT',
      title: 'Manila Open Series',
      schedule: 'Sep 21 · 6:00 PM',
      teams: '12 / 16 teams',
      icon: Icons.track_changes_rounded,
    ),
    _TournamentPreview(
      game: 'MOBILE LEGENDS',
      title: 'Campus Clash',
      schedule: 'Sep 28 · 1:00 PM',
      teams: '24 / 32 teams',
      icon: Icons.shield_rounded,
    ),
    _TournamentPreview(
      game: 'BASKETBALL',
      title: 'City Courts 3x3',
      schedule: 'Oct 05 · 9:00 AM',
      teams: '8 / 12 teams',
      icon: Icons.sports_basketball_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth >= 900 ? 48.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(compact: constraints.maxWidth < 500),
                    const SizedBox(height: 32),
                    _HeroCard(onExploreTournaments: onExploreTournaments),
                    const SizedBox(height: 40),
                    const PageHeader(
                      eyebrow: 'Discover',
                      title: 'Ready for the next match?',
                      description: 'Explore upcoming competitions and find the arena that fits your squad.',
                    ),
                    const SizedBox(height: 20),
                    _TournamentGrid(
                      tournaments: _tournaments,
                      wide: constraints.maxWidth >= 760,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.bolt_rounded, color: theme.colorScheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOURNA',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              if (!compact)
                Text(
                  'Play. Compete. Belong.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onExploreTournaments});

  final VoidCallback onExploreTournaments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -48,
              top: -56,
              child: _GlowCircle(
                size: 220,
                color: colors.onPrimary.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              right: 70,
              bottom: -72,
              child: _GlowCircle(
                size: 180,
                color: colors.onPrimary.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'YOUR COMPETITIVE HOME',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Text(
                      'Every match starts with a challenge.',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      'Discover tournaments, rally your team, and follow the action from one arena.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.88),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const Key('explore-tournaments'),
                    onPressed: onExploreTournaments,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.onPrimary,
                      foregroundColor: colors.primary,
                    ),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Explore tournaments'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TournamentGrid extends StatelessWidget {
  const _TournamentGrid({required this.tournaments, required this.wide});

  final List<_TournamentPreview> tournaments;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: [
          for (final tournament in tournaments) ...[
            _TournamentCard(tournament: tournament),
            const SizedBox(height: 16),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < tournaments.length; index++) ...[
          Expanded(child: _TournamentCard(tournament: tournaments[index])),
          if (index != tournaments.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard({required this.tournament});

  final _TournamentPreview tournament;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    tournament.icon,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              tournament.game,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(tournament.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _MetadataRow(
              icon: Icons.calendar_today_outlined,
              label: tournament.schedule,
            ),
            const SizedBox(height: 8),
            _MetadataRow(icon: Icons.groups_outlined, label: tournament.teams),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _TournamentPreview {
  const _TournamentPreview({
    required this.game,
    required this.title,
    required this.schedule,
    required this.teams,
    required this.icon,
  });

  final String game;
  final String title;
  final String schedule;
  final String teams;
  final IconData icon;
}
