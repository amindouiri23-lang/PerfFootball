import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync.dart';
import '../features/auth/auth_repository.dart';

// Rôles et permissions (migration 20261019000001). Le rôle vient du jeton (app_metadata.role) ; la matrice
// du rôle et les exceptions du compte sont lues à chaque synchronisation et gardées sur l'appareil, pour
// que les écrans s'adaptent aussi hors ligne. Le serveur refuse de toute façon ce que la matrice interdit.

const roleLabels = {
  'admin': 'Administrateur',
  'technical_director': 'Directeur technique',
  'head_coach': 'Entraîneur principal',
  'fitness_coach': 'Préparateur physique',
  'assistant_coach': 'Entraîneur adjoint',
  'medical': 'Médical (kiné, médecin)',
  'observer': 'Observateur',
  'player': 'Joueur',
};

const roleDescriptions = {
  'admin': 'Tout, dans toutes ses équipes, et la gestion des comptes et des permissions.',
  'technical_director': 'Tout dans ses équipes.',
  'head_coach': 'Tout dans ses équipes, sauf la gestion des comptes.',
  'fitness_coach': 'Comme l\'entraîneur principal, sans supprimer ni modifier le dossier médical.',
  'assistant_coach': 'Séances, appel, matchs, tactiques ; le reste en lecture.',
  'medical': 'Blessures, dossier médical, bien-être ; le reste en lecture.',
  'observer': 'Voit tout sauf le dossier médical, ne modifie rien.',
  'player': 'Remplit seulement son dossier, son RPE et son questionnaire de bien-être.',
};

/// Rôles dont la matrice se règle (administrateur : tout ; joueur : son propre espace).
const configurableRoles = ['technical_director', 'head_coach', 'fitness_coach', 'assistant_coach', 'medical', 'observer'];

class PermissionFeature {
  const PermissionFeature(this.key, this.label, this.actions);

  final String key;
  final String label;
  /// Action → libellé affiché.
  final Map<String, String> actions;
}

/// Catalogue : écran (fonctionnalité) × actions. Les clés sont celles du serveur (feature.action).
const permissionCatalog = [
  PermissionFeature('effectif', 'Effectif et joueurs', {'view': 'Voir', 'add': 'Ajouter', 'edit': 'Modifier', 'delete': 'Supprimer'}),
  PermissionFeature('dossier', 'Dossier joueur', {'view': 'Voir', 'edit': 'Modifier'}),
  PermissionFeature('medical', 'Dossier médical', {'view': 'Voir', 'edit': 'Modifier'}),
  PermissionFeature('seances', 'Séances', {
    'view': 'Voir', 'add': 'Ajouter', 'edit': 'Modifier et préparer (exercices)', 'delete': 'Supprimer',
    'appel': 'Faire l\'appel et clôturer', 'commenter': 'Commenter',
  }),
  PermissionFeature('bienetre', 'Bien-être', {'view': 'Voir', 'edit': 'Lancer et remplir les questionnaires'}),
  PermissionFeature('matchs', 'Matchs', {
    'view': 'Voir', 'add': 'Ajouter', 'edit': 'Modifier', 'delete': 'Supprimer',
    'jouer': 'Composition, feuille de match, buts, cartons, fin', 'issues': 'Forfait, report, annulation',
  }),
  PermissionFeature('blessures', 'Blessures et infirmerie', {'view': 'Voir', 'add': 'Déclarer', 'edit': 'Modifier'}),
  PermissionFeature('tests', 'Tests physiques', {'view': 'Voir', 'add': 'Ajouter', 'edit': 'Modifier', 'delete': 'Supprimer'}),
  PermissionFeature('tactiques', 'Tactiques', {'view': 'Voir', 'add': 'Ajouter', 'edit': 'Modifier', 'delete': 'Supprimer'}),
  PermissionFeature('import', 'Import Excel', {'use': 'Importer'}),
  PermissionFeature('equipes', 'Équipes', {'add': 'Créer', 'edit': 'Modifier'}),
  PermissionFeature('analyse', 'Tableau de bord', {'view': 'Voir', 'export': 'Exporter (PDF, Excel)'}),
];

/// Libellé d'une permission : « Matchs — Supprimer ».
String permissionLabel(String key) {
  final [feature, action] = key.split('.');
  final f = permissionCatalog.where((f) => f.key == feature).firstOrNull;
  return f == null ? key : '${f.label} — ${f.actions[action] ?? action}';
}

/// Droits du compte connecté.
class Perms {
  const Perms({required this.role, this.playerId, this.rolePerms = const {}, this.overrides = const {}});

  final String role;
  final String? playerId;
  final Map<String, bool> rolePerms;
  final Map<String, bool> overrides;

  bool get isAdmin => role == 'admin';
  bool get isPlayer => role == 'player';

  bool can(String key) => isAdmin || (!isPlayer && (overrides[key] ?? rolePerms[key] ?? false));
}

/// Clé du réglage local où la synchronisation range la matrice du rôle et les exceptions du compte.
const permissionsSettingKey = 'permissions';

final _cachedPermissionsProvider = StreamProvider<String?>(
  (ref) => ref.watch(databaseProvider).watchSetting(permissionsSettingKey),
);

final permsProvider = Provider<Perms>((ref) {
  final user = ref.watch(currentUserProvider).value ?? ref.watch(supabaseProvider).auth.currentUser;
  final role = user?.appMetadata['role'] as String? ?? 'observer';
  final playerId = user?.appMetadata['player_id'] as String?;
  final raw = ref.watch(_cachedPermissionsProvider).value;
  final j = raw == null ? const <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;
  Map<String, bool> map(Object? m) => {for (final e in (m as Map<String, dynamic>? ?? const {}).entries) e.key: e.value == true};
  return Perms(
    role: role,
    playerId: playerId,
    // Matrice d'un autre rôle (rôle changé depuis la dernière synchronisation) : ignorée.
    rolePerms: j['role'] == role ? map(j['role_perms']) : const {},
    overrides: map(j['overrides']),
  );
});
