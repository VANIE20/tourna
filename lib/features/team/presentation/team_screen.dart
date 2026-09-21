import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';
import 'package:tourna/features/team/domain/team.dart';
import 'package:tourna/features/team/domain/team_repository.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({required this.repository, super.key});

  final TeamRepository repository;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<Team?> _team;
  bool _isMutating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(TeamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _refresh();
  }

  void _refresh() {
    _team = widget.repository.loadCurrentTeam();
  }

  Future<void> _createTeam() async {
    final name = await _requestText(
      title: 'Create a team',
      label: 'Team name',
      helper: '2–40 characters',
      submitLabel: 'Create team',
      validator: _validateTeamName,
    );
    if (name == null) return;
    await _mutate(() => widget.repository.createTeam(name: name));
  }

  Future<void> _joinTeam() async {
    final code = await _requestText(
      title: 'Join a team',
      label: 'Team code',
      helper: 'Ask your captain for the 10-character code.',
      submitLabel: 'Join team',
      validator: _validateJoinCode,
      textCapitalization: TextCapitalization.characters,
    );
    if (code == null) return;
    await _mutate(() => widget.repository.joinTeam(joinCode: code));
  }

  Future<void> _leaveTeam(Team team) async {
    final disband = team.currentUserRole == TeamMemberRole.captain;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disband ? 'Disband team?' : 'Leave team?'),
        content: Text(
          disband
              ? 'You are the only member. This permanently removes ${team.name}.'
              : 'You’ll need a new invite code to rejoin ${team.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(disband ? 'Disband' : 'Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _mutate(() async {
      await widget.repository.leaveTeam();
      return null;
    });
  }

  Future<void> _mutate(Future<Team?> Function() operation) async {
    setState(() {
      _error = null;
      _isMutating = true;
    });
    try {
      final team = await operation();
      if (mounted) setState(() => _team = Future.value(team));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<String?> _requestText({
    required String title,
    required String label,
    required String helper,
    required String submitLabel,
    required String? Function(String?) validator,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _TeamTextDialog(
        title: title,
        label: label,
        helper: helper,
        submitLabel: submitLabel,
        validator: validator,
        textCapitalization: textCapitalization,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Team?>(
        future: _team,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading team'),
            );
          }
          if (snapshot.hasError) {
            return _TeamLoadError(
              onRetry: () => setState(() {
                _error = null;
                _refresh();
              }),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: snapshot.data == null
                    ? _NoTeam(
                        isLoading: _isMutating,
                        error: _error,
                        onCreate: _createTeam,
                        onJoin: _joinTeam,
                      )
                    : _TeamDetails(
                        team: snapshot.data!,
                        isLoading: _isMutating,
                        error: _error,
                        onLeave: () => _leaveTeam(snapshot.data!),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TeamTextDialog extends StatefulWidget {
  const _TeamTextDialog({
    required this.title,
    required this.label,
    required this.helper,
    required this.submitLabel,
    required this.validator,
    required this.textCapitalization,
  });

  final String title;
  final String label;
  final String helper;
  final String submitLabel;
  final String? Function(String?) validator;
  final TextCapitalization textCapitalization;

  @override
  State<_TeamTextDialog> createState() => _TeamTextDialogState();
}

class _TeamTextDialogState extends State<_TeamTextDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('team-dialog-input'),
          controller: _controller,
          autofocus: true,
          textCapitalization: widget.textCapitalization,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helper,
          ),
          validator: widget.validator,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('team-dialog-submit'),
          onPressed: _submit,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}

class _NoTeam extends StatelessWidget {
  const _NoTeam({
    required this.isLoading,
    required this.error,
    required this.onCreate,
    required this.onJoin,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          eyebrow: 'Your squad',
          title: 'Compete together',
          description: 'Create a team or use a captain’s invite code to join their roster.',
        ),
        const SizedBox(height: 32),
        if (error != null) _InlineError(message: error!),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.groups_rounded, size: 48, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Build your roster',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'One player can belong to one team at a time.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('create-team'),
                  onPressed: isLoading ? null : onCreate,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Team'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('join-team'),
                  onPressed: isLoading ? null : onJoin,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Join Team'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamDetails extends StatelessWidget {
  const _TeamDetails({
    required this.team,
    required this.isLoading,
    required this.error,
    required this.onLeave,
  });

  final Team team;
  final bool isLoading;
  final String? error;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isCaptain = team.currentUserRole == TeamMemberRole.captain;
    final captain = team.captain;
    final captainCanDisband = isCaptain && team.members.length == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          eyebrow: isCaptain ? 'Captain' : 'Team member',
          title: team.name,
          description: captain == null
              ? '${team.members.length} active players'
              : 'Led by ${captain.displayName} · ${team.members.length} active players',
        ),
        const SizedBox(height: 32),
        if (error != null) _InlineError(message: error!),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: const Icon(Icons.shield_rounded),
            ),
            title: Text('Team code', style: theme.textTheme.titleMedium),
            subtitle: Text(
              team.joinCode,
              key: const Key('team-join-code'),
              style: theme.textTheme.titleLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'ROSTER',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final member in team.members)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text(member.initials)),
              title: Text(member.displayName),
              subtitle: Text('@${member.username}'),
              trailing: member.role == TeamMemberRole.captain
                  ? const Chip(
                      avatar: Icon(Icons.star_rounded, size: 18),
                      label: Text('Captain'),
                    )
                  : const Text('Player'),
            ),
          ),
        const SizedBox(height: 20),
        if (isCaptain && !captainCanDisband)
          Text(
            'Transfer ownership before leaving a team with other members.',
            style: TextStyle(color: colors.onSurfaceVariant),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('leave-team'),
              onPressed: isLoading ? null : onLeave,
              icon: Icon(
                captainCanDisband ? Icons.delete_outline : Icons.logout_rounded,
              ),
              label: Text(captainCanDisband ? 'Disband team' : 'Leave team'),
            ),
          ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
      ),
    );
  }
}

class _TeamLoadError extends StatelessWidget {
  const _TeamLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load your team',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

String? _validateTeamName(String? value) {
  final name = value?.trim() ?? '';
  if (name.length < 2) return 'Enter at least 2 characters.';
  if (name.length > 40) return 'Keep the name under 40 characters.';
  return null;
}

String? _validateJoinCode(String? value) {
  final code = value?.trim() ?? '';
  if (!RegExp(r'^[a-fA-F0-9]{10}$').hasMatch(code)) {
    return 'Enter the 10-character team code.';
  }
  return null;
}
