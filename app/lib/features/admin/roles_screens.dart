import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../auth/auth_repository.dart';
import '../profile/profile_repository.dart';
import 'admin_repository.dart';
import 'team_picker.dart';

/// Choix du rôle et, pour un compte joueur, du joueur relié.
class RoleField extends ConsumerWidget {
  const RoleField({super.key, required this.role, required this.playerId, required this.onChanged});

  final String? role;
  final String? playerId;
  final void Function(String role, String? playerId, AdminPlayer? player) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DropdownButtonFormField<String>(
        initialValue: role,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Rôle *'),
        items: [for (final e in roleLabels.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
        onChanged: (v) => v == null ? null : onChanged(v, v == 'player' ? playerId : null, null),
        validator: (v) => v == null ? 'Obligatoire' : null,
      ),
      if (role != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(roleDescriptions[role]!, style: theme.textTheme.bodySmall),
        ),
      if (role == 'player') ...[
        const SizedBox(height: 12),
        _PlayerPicker(playerId: playerId, onChanged: (p) => onChanged('player', p.id, p)),
      ],
    ]);
  }
}

class _PlayerPicker extends ConsumerWidget {
  const _PlayerPicker({required this.playerId, required this.onChanged});

  final String? playerId;
  final ValueChanged<AdminPlayer> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(adminPlayersProvider);
    final teams = {for (final t in ref.watch(adminTeamsProvider).value ?? const <AdminTeam>[]) t.id: t};
    final list = players.value ?? const <AdminPlayer>[];
    final chosen = list.where((p) => p.id == playerId).firstOrNull;
    String team(AdminPlayer p) => [teams[p.teamId]?.clubName, teams[p.teamId]?.name].whereType<String>().join(' · ');
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Joueur relié au compte *', contentPadding: EdgeInsets.zero),
      child: ListTile(
        title: Text(chosen?.fullName ?? (players.isLoading ? 'Chargement…' : 'Choisir le joueur')),
        subtitle: chosen == null ? null : Text(team(chosen)),
        trailing: const Icon(Icons.search),
        onTap: list.isEmpty ? null : () async {
          final p = await _searchPlayer(context, list, team);
          if (p != null) onChanged(p);
        },
      ),
    );
  }
}

/// Recherche d'un joueur par son nom, parmi les joueurs de toutes les équipes.
Future<AdminPlayer?> _searchPlayer(BuildContext context, List<AdminPlayer> all, String Function(AdminPlayer) team) {
  var query = '';
  return showModalBottomSheet<AdminPlayer>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      final q = query.toLowerCase();
      final shown = all.where((p) => '${p.fullName} ${p.lastName} ${p.firstName}'.toLowerCase().contains(q)).take(50).toList();
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Nom du joueur'),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
            Expanded(
              child: ListView(children: [
                for (final p in shown)
                  ListTile(title: Text(p.fullName), subtitle: Text(team(p)), onTap: () => Navigator.of(context).pop(p)),
              ]),
            ),
          ]),
        ),
      );
    }),
  );
}

/// Fiche d'un compte : rôle, joueur relié, équipes et exceptions aux permissions de son rôle.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  String? _role;
  String? _playerId;
  bool _busy = false;

  Future<void> _saveRole(StaffAccount a) async {
    if (_role == 'player' && _playerId == null) {
      showMessage(context, 'Choisissez le joueur relié au compte.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).setRole(a.id, _role!, playerId: _playerId);
      ref.invalidate(staffAccountsProvider);
      if (mounted) showMessage(context, 'Rôle enregistré. Il s\'applique à la prochaine synchronisation du compte.');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setOverride(String permission, bool? allowed) async {
    try {
      await ref.read(adminRepositoryProvider).setAccountPermission(widget.userId, permission, allowed);
      ref.invalidate(accountPermissionsProvider(widget.userId));
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(staffAccountsProvider);
    final me = ref.watch(currentUserProvider).value?.id;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Compte')),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : networkErrorMessage)),
        data: (list) {
          final a = list.where((x) => x.id == widget.userId).firstOrNull;
          if (a == null) return const Center(child: Text('Compte introuvable.'));
          _role ??= a.role;
          _playerId ??= a.playerId;
          final self = a.id == me;
          final teams = {for (final t in ref.watch(adminTeamsProvider).value ?? const <AdminTeam>[]) t.id: t};
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(a.initials)),
              title: Text(a.displayName, style: theme.textTheme.titleMedium),
              subtitle: Text([a.email, if (a.jobTitle != null) jobTitles[a.jobTitle], if (a.isDisabled) 'désactivé'].join(' · ')),
            ),
            const SizedBox(height: 8),
            Text('Rôle', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (self)
              Text('${roleLabels[a.role]} — vous ne pouvez pas changer votre propre rôle.')
            else ...[
              RoleField(
                role: _role,
                playerId: _playerId,
                onChanged: (r, p, _) => setState(() {
                  _role = r;
                  _playerId = p;
                }),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _busy || (_role == a.role && _playerId == a.playerId) ? null : () => _saveRole(a),
                  child: Text(_busy ? 'Enregistrement…' : 'Enregistrer le rôle'),
                ),
              ),
            ],
            const Divider(height: 32),
            Text('Équipes', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(a.teamIds.isEmpty ? 'Aucune équipe.' : [for (final t in a.teamIds) teams[t]?.name ?? '—'].join(', ')),
            if (a.role != 'player' && !self)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => showAccountTeams(context, ref, a),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier les équipes'),
                ),
              ),
            const Divider(height: 32),
            Text('Permissions', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (a.role == 'admin')
              const Text('Administrateur : tous les droits, dans toutes ses équipes.')
            else if (a.role == 'player')
              const Text('Compte joueur : il remplit seulement son dossier, son RPE et son questionnaire de bien-être.')
            else
              _Overrides(account: a, onChanged: _setOverride),
          ]);
        },
      ),
    );
  }
}

/// Exceptions du compte, écran par écran : « Rôle » (la matrice décide), « Oui » ou « Non ».
class _Overrides extends ConsumerWidget {
  const _Overrides({required this.account, required this.onChanged});

  final StaffAccount account;
  final Future<void> Function(String permission, bool? allowed) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matrix = ref.watch(rolePermissionsProvider).value?[account.role] ?? const <String, bool>{};
    final overrides = ref.watch(accountPermissionsProvider(account.id));
    final theme = Theme.of(context);
    return overrides.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(e is AppException ? e.message : networkErrorMessage),
      data: (o) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          'Par défaut, le compte a les droits de son rôle (${roleLabels[account.role]}). Choisissez « Oui » ou « Non » '
          'pour faire une exception pour ce compte seulement.',
          style: theme.textTheme.bodySmall,
        ),
        if (o.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${o.length} exception${o.length > 1 ? 's' : ''} pour ce compte.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ),
        for (final f in permissionCatalog)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(f.label),
            subtitle: [for (final a in f.actions.keys) '${f.key}.$a'].any(o.containsKey)
                ? Text('Exception', style: TextStyle(color: theme.colorScheme.primary))
                : null,
            children: [
              for (final e in f.actions.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.value),
                        Text('Rôle : ${(matrix['${f.key}.${e.key}'] ?? false) ? 'oui' : 'non'}', style: theme.textTheme.bodySmall),
                      ]),
                    ),
                    SegmentedButton<bool?>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: null, label: Text('Rôle')),
                        ButtonSegment(value: true, label: Text('Oui')),
                        ButtonSegment(value: false, label: Text('Non')),
                      ],
                      selected: {o['${f.key}.${e.key}']},
                      onSelectionChanged: (v) => onChanged('${f.key}.${e.key}', v.first),
                    ),
                  ]),
                ),
            ],
          ),
      ]),
    );
  }
}

/// Matrice des permissions : pour chaque rôle, ce qu'il peut voir et faire, écran par écran.
class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  String _role = configurableRoles.first;
  /// Cases modifiées et pas encore relues du serveur (affichage immédiat).
  final Map<String, bool> _pending = {};

  Future<void> _toggle(String permission, bool allowed) async {
    setState(() => _pending['$_role|$permission'] = allowed);
    try {
      await ref.read(adminRepositoryProvider).setRolePermission(_role, permission, allowed);
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _pending.remove('$_role|$permission'));
        showMessage(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = ref.watch(rolePermissionsProvider);
    final accounts = ref.watch(staffAccountsProvider).value ?? const <StaffAccount>[];
    final theme = Theme.of(context);
    final count = accounts.where((a) => a.role == _role).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Rôles et permissions')),
      body: matrix.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : networkErrorMessage)),
        data: (m) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in configurableRoles)
              ChoiceChip(label: Text(roleLabels[r]!), selected: _role == r, onSelected: (_) => setState(() => _role = r)),
          ]),
          const SizedBox(height: 12),
          Text(roleDescriptions[_role]!, style: theme.textTheme.bodyMedium),
          Text('$count compte${count > 1 ? 's' : ''} avec ce rôle. Une case modifiée s\'applique à tous ces comptes '
              '(à leur prochaine synchronisation), sauf exception réglée sur leur fiche.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Administrateur : tous les droits. Joueur : son dossier, son RPE et son bien-être. Ces deux rôles ne se règlent pas ici.',
              style: theme.textTheme.bodySmall),
          for (final f in permissionCatalog)
            Card(
              margin: const EdgeInsets.only(top: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(f.label, style: theme.textTheme.titleSmall)),
                  for (final e in f.actions.entries)
                    CheckboxListTile(
                      dense: true,
                      title: Text(e.value),
                      value: _pending['$_role|${f.key}.${e.key}'] ?? m[_role]?['${f.key}.${e.key}'] ?? false,
                      onChanged: (v) => _toggle('${f.key}.${e.key}', v ?? false),
                    ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Raccourci : ouvrir la fiche d'un compte.
void openAccount(BuildContext context, StaffAccount a) => context.go('/profile/admin/account/${a.id}');
