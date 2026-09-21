import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    required this.submitLabel,
    required this.onSubmit,
    this.initialUsername = '',
    this.initialDisplayName = '',
    super.key,
  });

  final String initialUsername;
  final String initialDisplayName;
  final String submitLabel;
  final Future<void> Function(String username, String displayName) onSubmit;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _displayNameController = TextEditingController(
      text: widget.initialDisplayName,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        _usernameController.text.trim().toLowerCase(),
        _displayNameController.text.trim(),
      );
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            key: const Key('profile-username'),
            controller: _usernameController,
            enabled: !_isSaving,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 24,
            decoration: const InputDecoration(
              labelText: 'Username',
              helperText: '3–24 lowercase letters, numbers, or underscores.',
              prefixText: '@',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: validateUsername,
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('profile-display-name'),
            controller: _displayNameController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 50,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Display name',
              helperText: 'The name your teammates will see.',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: validateDisplayName,
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('profile-submit'),
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

String? validateUsername(String? value) {
  final username = value?.trim().toLowerCase() ?? '';
  if (username.isEmpty) return 'Choose a username.';
  if (username.length < 3) return 'Username must be at least 3 characters.';
  if (username.length > 24) return 'Username must be 24 characters or fewer.';
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
    return 'Use only lowercase letters, numbers, and underscores.';
  }
  return null;
}

String? validateDisplayName(String? value) {
  final displayName = value?.trim() ?? '';
  if (displayName.isEmpty) return 'Enter your display name.';
  if (displayName.length < 2) return 'Display name is too short.';
  if (displayName.length > 50) {
    return 'Display name must be 50 characters or fewer.';
  }
  return null;
}
