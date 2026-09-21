import 'package:flutter/material.dart';
import 'package:tourna/features/home/presentation/home_screen.dart';
import 'package:tourna/features/live/presentation/live_screen.dart';
import 'package:tourna/features/profile/presentation/profile_screen.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';
import 'package:tourna/features/team/domain/team_repository.dart';
import 'package:tourna/features/team/presentation/team_screen.dart';
import 'package:tourna/features/tournaments/presentation/tournaments_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.profile,
    required this.profileRepository,
    required this.teamRepository,
    this.onSignOut,
    super.key,
  });

  final UserProfile profile;
  final ProfileRepository profileRepository;
  final TeamRepository teamRepository;
  final Future<void> Function()? onSignOut;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _destinations = <_AppDestination>[
    _AppDestination(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _AppDestination(
      label: 'Tournaments',
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events_rounded,
    ),
    _AppDestination(
      label: 'Team',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
    ),
    _AppDestination(
      label: 'Live',
      icon: Icons.sensors_outlined,
      selectedIcon: Icons.sensors_rounded,
    ),
    _AppDestination(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  int _selectedIndex = 0;

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        HomeScreen(onExploreTournaments: () => _selectDestination(1)),
        const TournamentsScreen(),
        TeamScreen(repository: widget.teamRepository),
        const LiveScreen(),
        ProfileScreen(
          profile: widget.profile,
          repository: widget.profileRepository,
          onSignOut: widget.onSignOut,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          final extended = constraints.maxWidth >= 1100;
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  right: false,
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    extended: extended,
                    labelType: extended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _BrandMark(showWordmark: extended),
                    ),
                    destinations: [
                      for (final item in _destinations)
                        NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectDestination,
            destinations: [
              for (final item in _destinations)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.showWordmark});

  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.bolt_rounded, color: theme.colorScheme.onPrimary),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 12),
          Text(
            'TOURNA',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
