import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/database.dart';
import '../team/team_repository.dart';
import '../team/team_screen.dart';
import 'session_repository.dart';

/// E11 — Liste des séances : « À venir » (de la plus proche à la plus lointaine) puis « Passées »
/// (de la plus récente à la plus ancienne), regroupées par semaine.
class SessionsListScreen extends ConsumerStatefulWidget {
  const SessionsListScreen({super.key});

  @override
  ConsumerState<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends ConsumerState<SessionsListScreen> {
  String? _type;

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final sessions = (ref.watch(sessionsProvider(team.id)).value ?? const <TrainingSession>[])
        .where((s) => _type == null || s.type == _type)
        .toList();
    final rows = ref.watch(teamSessionPlayersProvider(team.id)).value ?? const <SessionPlayer>[];
    final today = isoDate(DateTime.now());
    String key(TrainingSession s) => '${s.date} ${s.startTime}';
    final upcoming = sessions.where((s) => s.date.compareTo(today) >= 0 && s.status == 'planned').toList()
      ..sort((a, b) => key(a).compareTo(key(b)));
    final past = sessions.where((s) => !upcoming.contains(s)).toList()..sort((a, b) => key(b).compareTo(key(a)));

    return Scaffold(
      appBar: AppBar(title: const Text('Séances'), actions: const [SyncIndicator()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sessions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            for (final e in <String?, String>{null: 'Tous types', ...sessionTypes}.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(e.value), selected: _type == e.key,
                    onSelected: (_) => setState(() => _type = e.key)),
              ),
          ]),
        ),
        if (sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Text('Aucune séance pour l\'instant. Créez votre première séance.', textAlign: TextAlign.center),
          ),
        if (upcoming.isNotEmpty) ...[
          const _Header('À venir'),
          for (final s in upcoming) _SessionTile(s, rows),
        ],
        if (past.isNotEmpty) ...[
          const _Header('Passées'),
          ..._byWeek(past, rows),
        ],
      ]),
    );
  }

  List<Widget> _byWeek(List<TrainingSession> list, List<SessionPlayer> rows) {
    final out = <Widget>[];
    String? current;
    for (final s in list) {
      final monday = s.day.subtract(Duration(days: s.day.weekday - 1));
      final week = 'Semaine du ${DateFormat('d MMMM', 'fr_FR').format(monday)}';
      if (week != current) {
        current = week;
        out.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(week, style: Theme.of(context).textTheme.labelMedium),
        ));
      }
      out.add(_SessionTile(s, rows));
    }
    return out;
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile(this.s, this.rows);

  final TrainingSession s;
  final List<SessionPlayer> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = rows.where((r) => r.sessionId == s.id).toList();
    final presence = mine.isEmpty ? '' : ' · ${mine.where((r) => r.present).length}/${mine.length}';
    return ListTile(
      leading: CircleAvatar(radius: 6, backgroundColor: sessionTypeColors[s.type]),
      minLeadingWidth: 12,
      title: Text('${s.dayLabel} · ${s.time}'),
      subtitle: Text('${sessionTypes[s.type]} · ${s.plannedDurationMin} min$presence'),
      onTap: () => context.go('/sessions/${s.id}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        StatusChip(s.status),
        PopupMenuButton<String>(
          tooltip: 'Actions',
          onSelected: (v) => v == 'edit' ? context.go('/sessions/${s.id}/edit') : confirmDeleteSession(context, ref, s),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ]),
    );
  }
}

/// Pastille d'état d'une séance ou d'un match.
class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.labels = sessionStatuses});

  final String status;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      'in_progress' => (c.tertiaryContainer, c.onTertiaryContainer),
      'completed' => (c.primaryContainer, c.onPrimaryContainer),
      _ => (c.surfaceContainerHighest, c.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(labels[status] ?? status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// Confirmation de suppression (E11) ; renvoie true si la séance a été supprimée.
Future<bool> confirmDeleteSession(BuildContext context, WidgetRef ref, TrainingSession s) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer la séance du ${s.dayLabel} ?'),
      content: const Text('L\'appel, les remarques et le bien-être de cette séance seront supprimés. '
          'Les blessures déclarées sont conservées.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(sessionRepositoryProvider).deleteSession(s.id);
  if (context.mounted) showMessage(context, 'Séance supprimée');
  return true;
}
