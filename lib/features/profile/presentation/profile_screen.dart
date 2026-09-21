import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';
import 'package:tourna/features/profile/domain/profile_repository.dart';
import 'package:tourna/features/profile/domain/user_profile.dart';
import 'package:tourna/features/profile/presentation/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.profile,
    required this.repository,
    this.onSignOut,
    super.key,
  });

  final UserProfile profile;
  final ProfileRepository repository;
  final Future<void> Function()? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _profile = widget.profile;
  }

  Future<void> _editProfile() async {
    final updated = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit player profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account role is managed separately for your security.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ProfileForm(
                  initialUsername: _profile.username,
                  initialDisplayName: _profile.displayName,
                  submitLabel: 'Save changes',
                  onSubmit: (username, displayName) async {
                    final profile = await widget.repository.updateProfile(
                      username: username,
                      displayName: displayName,
                    );
                    if (context.mounted) Navigator.pop(context, profile);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (updated != null && mounted) setState(() => _profile = updated);
  }

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
                PageHeader(
                  eyebrow: 'Player profile',
                  title: _profile.displayName,
                  description:
                      'Your persistent TOURNA identity and account details.',
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: colors.primaryContainer,
                              foregroundColor: colors.onPrimaryContainer,
                              child: Text(
                                _profile.initials,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@${_profile.username}',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  if (_profile.email != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _profile.email!,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.shield_outlined, color: colors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_profile.role.name[0].toUpperCase()}${_profile.role.name.substring(1)} account',
                              ),
                            ),
                            TextButton.icon(
                              key: const Key('edit-profile'),
                              onPressed: _editProfile,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.onSignOut != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('sign-out'),
                      onPressed: () async {
                        try {
                          await widget.onSignOut!();
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
