import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/router.dart';
import '../auth/auth_repository.dart';
import 'admin_repository.dart';

/// Comptes joueurs : un compte par joueur des équipes choisies (ceux qui en ont déjà un sont ignorés),
/// puis la fiche des identifiants et mots de passe temporaires à distribuer — affichée une seule fois.
class PlayerAccountsScreen extends ConsumerStatefulWidget {
  const PlayerAccountsScreen({super.key});

  @override
  ConsumerState<PlayerAccountsScreen> createState() => _PlayerAccountsScreenState();
}

class _PlayerAccountsScreenState extends ConsumerState<PlayerAccountsScreen> {
  final Set<String> _teams = {};
  bool _busy = false;
  String? _progress;
  final List<({String team, String name, String email, String password})> _created = [];

  Future<void> _create(List<AdminTeam> teams) async {
    setState(() {
      _busy = true;
      _created.clear();
    });
    try {
      for (final t in teams.where((t) => _teams.contains(t.id))) {
        setState(() => _progress = 'Création des comptes : ${t.name}…');
        final list = await ref.read(adminRepositoryProvider).createPlayerAccounts(t.id);
        setState(() => _created.addAll([for (final c in list) (team: t.name, name: c.name, email: c.email, password: c.password)]));
      }
      ref.invalidate(staffAccountsProvider);
      if (mounted) showMessage(context, '${_created.length} compte(s) créé(s)');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  /// Fiche au format CSV (s'ouvre dans Excel) : équipe, joueur, identifiant, mot de passe temporaire.
  Future<void> _share() async {
    String cell(String v) => '"${v.replaceAll('"', '""')}"';
    final csv = StringBuffer('﻿Équipe;Joueur;Identifiant;Mot de passe temporaire\r\n');
    for (final c in _created) {
      csv.write('${cell(c.team)};${cell(c.name)};${cell(c.email)};${cell(c.password)}\r\n');
    }
    await SharePlus.instance.share(ShareParams(
      title: 'Identifiants des joueurs',
      files: [XFile.fromData(utf8.encode(csv.toString()), mimeType: 'text/csv', name: 'identifiants_joueurs.csv')],
      fileNameOverrides: ['identifiants_joueurs.csv'],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(adminTeamsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Comptes joueurs')),
      body: teams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e is AppException ? e.message : networkErrorMessage)),
        data: (list) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          const Text('Chaque joueur reçoit un compte « Joueur » : il remplit son dossier, ses questionnaires de bien-être '
              'et son RPE des séances et des matchs. Les joueurs qui ont déjà un compte sont ignorés.'),
          const SizedBox(height: 12),
          for (final t in list)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _teams.contains(t.id),
              title: Text(t.name),
              subtitle: Text(t.clubName ?? ''),
              onChanged: _busy ? null : (v) => setState(() => v == true ? _teams.add(t.id) : _teams.remove(t.id)),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy || _teams.isEmpty ? null : () => _create(list),
            icon: const Icon(Icons.group_add_outlined),
            label: Text(_busy ? (_progress ?? 'Création…') : 'Créer les comptes'),
          ),
          if (_created.isNotEmpty) ...[
            const Divider(height: 32),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Mots de passe temporaires affichés une seule fois : enregistrez la fiche maintenant. '
                  'Chaque joueur choisit son propre mot de passe à sa première connexion.',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.download_outlined),
              label: Text('Enregistrer la fiche (${_created.length} joueurs)'),
            ),
            const SizedBox(height: 8),
            for (final c in _created)
              ListTile(
                dense: true,
                title: Text('${c.name} · ${c.team}'),
                subtitle: SelectableText('${c.email}\n${c.password}'),
              ),
          ],
        ]),
      ),
    );
  }
}
