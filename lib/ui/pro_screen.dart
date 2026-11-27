import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../services/pro.dart';
import 'theme.dart';

Future<void> showPro(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ProScreen()));

/// What Dose Pro adds, and the purchase through Google Play.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(proProvider.notifier).connect();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pro = ref.watch(proProvider);
    final busy = pro.status == ProStatus.buying;

    return Scaffold(
      appBar: AppBar(title: Text(l.proTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.xl,
          Spacing.lg,
          Spacing.xxl,
        ),
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 56,
            color: scheme.primary,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l.proTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l.proTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _Feature(
            icon: Icons.insights_outlined,
            title: l.proFeatureAnalytics,
            subtitle: l.proFeatureAnalyticsHint,
          ),
          _Feature(
            icon: Icons.inventory_2_outlined,
            title: l.proFeatureStock,
            subtitle: l.proFeatureStockHint,
          ),
          _Feature(
            icon: Icons.menu_book_outlined,
            title: l.proFeatureGuide,
            subtitle: l.proFeatureGuideHint,
          ),
          _Feature(
            icon: Icons.music_note_outlined,
            title: l.proFeatureSounds,
            subtitle: l.proFeatureSoundsHint,
          ),
          const SizedBox(height: Spacing.lg),
          Card(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(l.proFreeNote, style: theme.textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          if (pro.unlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: scheme.primary),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: Text(
                    l.proUnlockedThanks,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            )
          else ...[
            FilledButton(
              onPressed: busy
                  ? null
                  : () => ref.read(proProvider.notifier).buy(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: busy
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      pro.price == null
                          ? l.proBuyNoPrice
                          : l.proBuy(pro.price!),
                    ),
            ),
            if (pro.status == ProStatus.pending) ...[
              const SizedBox(height: Spacing.md),
              Text(
                l.proPending,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (pro.status == ProStatus.error) ...[
              const SizedBox(height: Spacing.md),
              Text(
                l.proError,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                ),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            TextButton(
              onPressed: busy
                  ? null
                  : () => ref.read(proProvider.notifier).restore(),
              child: Text(l.proRestore),
            ),
          ],
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title),
    subtitle: Text(subtitle),
  );
}

/// Stands in for a Pro screen's content without Pro.
class ProLockedBody extends StatelessWidget {
  const ProLockedBody({super.key, required this.feature});

  /// What this screen would show, e.g. "Detailed analytics".
  final String feature;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              feature,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l.proLocked,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton(
              onPressed: () => showPro(context),
              child: Text(l.proLearnMore),
            ),
          ],
        ),
      ),
    );
  }
}

/// A settings-style row for a Pro feature without Pro.
class ProLockedTile extends StatelessWidget {
  const ProLockedTile({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(l.proLocked),
      trailing: const Icon(Icons.workspace_premium_outlined),
      onTap: () => showPro(context),
    );
  }
}
