import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../auth/auth_repository.dart';
import 'admin_repository.dart';
import 'roles_screens.dart';
import 'team_picker.dart';

/// E29 — Comptes du staff.
class StaffAccountsScreen extends ConsumerStatefulWidget {
  const StaffAccountsScreen({super.key});

  @override
  ConsumerState<StaffAccountsScreen> createState() => _StaffAccountsScreenState();
}

class _StaffAccountsScreenState extends ConsumerState<StaffAccountsScreen> {
  String _query = '';

  Future<void> _reset(StaffAccount a) async {
    final ok = await _confirm(context, 'Réinitialiser le mot de passe ?',
        'Le mot de passe actuel de ${a.displayName} ne fonctionnera plus.', 'Réinitialiser');
    if (!ok || !mounted) return;
    try {
      final pwd = await ref.read(adminRepositoryProvider).resetPassword(a.id);
      ref.invalidate(staffAccountsProvider);
      if (mounted) await showTemporaryPassword(context, a.email, a.displayName, pwd);
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  Future<void> _toggle(StaffAccount a) async {
    final disable = !a.isDisabled;
    if (disable) {
      final ok = await _confirm(context, 'Désactiver le compte ?',
          '${a.displayName} ne pourra plus se connecter. Ses données sont conservées.', 'Désactiver');
      if (!ok) return;
    }
    try {
      await ref.read(adminRepositoryProvider).setDisabled(a.id, disable);
      ref.invalidate(staffAccountsProvider);
      if (mounted) showMessage(context, disable ? 'Compte désactivé' : 'Compte réactivé');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(staffAccountsProvider);
    final me = ref.watch(currentUserProvider).value?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Administration'), actions: [
        TextButton.icon(
          onPressed: () => context.go('/profile/admin/roles'),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text('Rôles'),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/profile/admin/new'),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Créer un compte'),
      ),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(e is AppException ? e.message : networkErrorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => ref.invalidate(staffAccountsProvider), child: const Text('Réessayer')),
          ]),
        )),
        data: (list) {
          final q = _query.toLowerCase();
          final shown = list.where((a) => a.displayName.toLowerCase().contains(q) || a.email.contains(q)).toList();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(staffAccountsProvider.future),
            child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un compte'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('${shown.length} compte${shown.length > 1 ? 's' : ''}'),
              ),
              for (final a in shown)
                ListTile(
                  enabled: !a.isDisabled,
                  leading: CircleAvatar(child: Text(a.initials)),
                  title: Text(a.displayName),
                  onTap: () => openAccount(context, a),
                  subtitle: Text([
                    a.email,
                    roleLabels[a.role] ?? a.role,
                    '${a.teamIds.length} équipe${a.teamIds.length > 1 ? 's' : ''}',
                  ].join(' · ')),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _StatusChip(a),
                    if (a.id != me)
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        onSelected: (v) => switch (v) {
                          'reset' => _reset(a),
                          'teams' => showAccountTeams(context, ref, a),
                          _ => _toggle(a),
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'teams', child: Text('Équipes')),
                          const PopupMenuItem(value: 'reset', child: Text('Réinitialiser le mot de passe')),
                          PopupMenuItem(value: 'toggle',
                              child: Text(a.isDisabled ? 'Réactiver le compte' : 'Désactiver le compte')),
                        ],
                      )
                    else
                      const SizedBox(width: 48),
                  ]),
                ),
            ]),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.a);

  final StaffAccount a;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final (label, bg, fg) = a.isDisabled
        ? ('Désactivé', c.errorContainer, c.onErrorContainer)
        : a.mustChangePassword
            ? ('Temporaire', c.tertiaryContainer, c.onTertiaryContainer)
            : a.isAdmin
                ? ('Admin', c.primaryContainer, c.onPrimaryContainer)
                : ('Actif', c.surfaceContainerHighest, c.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

/// E30 — Créer un compte.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  String? _role;
  /// Cases changées par rapport aux droits du rôle choisi.
  Map<String, bool> _perms = {};
  String? _playerId;
  bool _busy = false;
  Set<String> _teams = {};

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    if (_role == 'player' && _playerId == null) {
      showMessage(context, 'Choisissez le joueur relié au compte.');
      return;
    }
    setState(() => _busy = true);
    try {
      final email = _email.text.trim().toLowerCase();
      final pwd = await ref.read(adminRepositoryProvider).create(
          email: email, firstName: _first.text.trim(), lastName: _last.text.trim(),
          role: _role!, playerId: _playerId, permissions: _perms,
          teamIds: _role == 'player' ? const [] : _teams.toList());
      ref.invalidate(staffAccountsProvider);
      if (!mounted) return;
      await showTemporaryPassword(context, email, '${_first.text.trim()} ${_last.text.trim()}', pwd);
      if (mounted) context.go('/profile/admin');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: FormPage(title: 'Créer un compte', children: [
        TextFormField(controller: _first, decoration: const InputDecoration(labelText: 'Prénom *'), validator: _required),
        const SizedBox(height: 16),
        TextFormField(controller: _last, decoration: const InputDecoration(labelText: 'Nom *'), validator: _required),
        const SizedBox(height: 16),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Adresse e-mail *'),
          validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
              ? null : 'Adresse e-mail invalide.',
        ),
        const SizedBox(height: 16),
        RoleField(
          role: _role,
          playerId: _playerId,
          onChanged: (r, p, player) => setState(() {
            if (r != _role) _perms = {};
            _role = r;
            _playerId = p;
            // Compte joueur : nom repris de sa fiche si le formulaire est encore vide.
            if (player != null && _first.text.trim().isEmpty && _last.text.trim().isEmpty) {
              _first.text = player.firstName;
              _last.text = player.lastName;
            }
          }),
        ),
        if (_role != 'player') ...[
          const SizedBox(height: 16),
          Text('Équipes', style: Theme.of(context).textTheme.titleSmall),
          const Text('Le compte agit dans les équipes cochées, selon les permissions de son rôle.'),
          TeamPicker(selected: _teams, onChanged: (s) => setState(() => _teams = s)),
          if (_role != null && _role != 'admin') ...[
            const SizedBox(height: 16),
            Text('Écrans et actions', style: Theme.of(context).textTheme.titleSmall),
            Text('Cochées par défaut selon le rôle. Décochez ou cochez pour ce compte seulement.',
                style: Theme.of(context).textTheme.bodySmall),
            Builder(builder: (context) {
              final defaults = ref.watch(rolePermissionsProvider).value?[_role] ?? const <String, bool>{};
              return PermissionMatrix(
                values: {for (final k in {...defaults.keys, ..._perms.keys}) k: _perms[k] ?? defaults[k] ?? false},
                defaults: defaults,
                onChanged: (k, v) => setState(() => v == (defaults[k] ?? false) ? _perms.remove(k) : _perms[k] = v),
              );
            }),
          ],
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Le compte joueur rejoint automatiquement l\'équipe de son joueur.'),
          ),
        const SizedBox(height: 8),
        const Text('Un mot de passe temporaire sera généré. Aucun e-mail n\'est envoyé : '
            'vous le transmettrez vous-même.'),
        const SizedBox(height: 24),
        BusyButton(label: 'Créer le compte', busy: _busy, onPressed: _create),
      ]),
    );
  }
}

/// E31 — affichage unique du mot de passe temporaire.
Future<void> showTemporaryPassword(BuildContext context, String email, String name, String password) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Mot de passe temporaire'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Identifiant', style: theme.textTheme.labelMedium),
          SelectableText(email, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('Mot de passe temporaire', style: theme.textTheme.labelMedium),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(password, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          Text('Affiché une seule fois. $name devra le changer à sa connexion.'),
        ]),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copier'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: password));
              showMessage(context, 'Mot de passe copié');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            onPressed: () => SharePlus.instance.share(ShareParams(
                text: 'PerfFoot — identifiant : $email\nMot de passe temporaire : $password\n'
                    'Vous devrez le changer à la première connexion.')),
          ),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Terminé')),
        ],
      );
    },
  );
}

Future<bool> _confirm(BuildContext context, String title, String body, String action) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(action)),
      ],
    ),
  );
  return r ?? false;
}
