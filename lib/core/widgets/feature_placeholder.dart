import 'package:flutter/material.dart';
import 'package:tourna/core/widgets/page_header.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    required this.highlights,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final String status;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth >= 900 ? 48.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      eyebrow: eyebrow,
                      title: title,
                      description: description,
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phase 1 preview',
                                        style: theme.textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 8),
                            for (final highlight in highlights)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        highlight,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
    );
  }
}
