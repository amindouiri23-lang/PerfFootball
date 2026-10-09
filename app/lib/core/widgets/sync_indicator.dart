import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/sync.dart';
import '../settings.dart';
import 'steppers.dart';

/// Nuage en haut des écrans : nombre de modifications en attente d'envoi (specs §3.2).
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final status = ref.watch(syncControllerProvider);
    final c = Theme.of(context).colorScheme;
    final (icon, color, label) = status.syncing
        ? (Icons.cloud_sync_outlined, c.primary, null)
        : status.error != null
            ? (Icons.cloud_off_outlined, c.error, pending > 0 ? '$pending' : null)
            : pending > 0
                ? (Icons.cloud_upload_outlined, c.tertiary, '$pending')
                : (Icons.cloud_done_outlined, c.primary, null);
    return IconButton(
      tooltip: 'Synchronisation',
      onPressed: () => context.push('/sync'),
      icon: Badge(isLabelVisible: label != null, label: Text(label ?? ''), child: Icon(icon, color: color)),
    );
  }
}

/// E28 — Synchronisation et paramètres de l'appareil.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingCountProvider).value ?? 0;
    final status = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);
    final (title, color) = status.syncing
        ? ('Synchronisation en cours…', theme.colorScheme.primaryContainer)
        : status.error == 'Hors ligne'
            ? ('Hors ligne', theme.colorScheme.tertiaryContainer)
            : status.error != null
                ? ('Erreur', theme.colorScheme.errorContainer)
                : pending > 0
                    ? ('En attente', theme.colorScheme.tertiaryContainer)
                    : ('À jour', theme.colorScheme.primaryContainer);
    final last = status.lastSuccess == null
        ? 'aucune depuis l\'ouverture de l\'application'
        : DateFormat("d MMMM 'à' HH:mm", 'fr_FR').format(status.lastSuccess!);
    return Scaffold(
      appBar: AppBar(title: const Text('Synchronisation et paramètres')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(pending == 0 ? 'Toutes les données sont envoyées.' : '$pending donnée${pending > 1 ? 's' : ''} en attente d\'envoi.'),
              Text('Dernière synchronisation réussie : $last'),
              if (status.error == 'Hors ligne')
                const Text('La synchronisation partira automatiquement au retour du réseau.'),
              if (status.error != null && status.error != 'Hors ligne') ...[
                const SizedBox(height: 8),
                Text(status.error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: status.syncing ? null : () => ref.read(syncControllerProvider.notifier).sync(),
          icon: const Icon(Icons.sync),
          label: const Text('Synchroniser maintenant'),
        ),
        const SizedBox(height: 32),
        Text('Paramètres', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Text('Thème', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final e in themeModes.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: (ref.watch(themeSettingProvider).value ?? 'system') == e.key,
              onSelected: (_) => ref.read(databaseProvider).setSetting(themeKey, e.key),
            ),
        ]),
        const SizedBox(height: 16),
        _DurationSetting(label: 'Durée de séance par défaut', settingKey: sessionDurationKey, min: 10, max: 240),
        _DurationSetting(label: 'Durée de match par défaut', settingKey: matchDurationKey, min: 20, max: 130),
        const SizedBox(height: 24),
        Text('À propos', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('PerfFoot — version $appVersion ($appBuild)'),
      ]),
    );
  }
}

class _DurationSetting extends ConsumerWidget {
  const _DurationSetting({required this.label, required this.settingKey, required this.min, required this.max});

  final String label;
  final String settingKey;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(defaultDurationProvider(settingKey)).value ?? 90;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(label)),
        MinutesStepper(
          value: value,
          min: min,
          max: max,
          onChanged: (v) => ref.read(databaseProvider).setSetting(settingKey, '$v'),
        ),
      ]),
    );
  }
}
