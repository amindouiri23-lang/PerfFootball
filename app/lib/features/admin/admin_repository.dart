import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_repository.dart';

class StaffAccount {
  const StaffAccount({required this.id, required this.email, this.firstName, this.lastName, this.jobTitle,
      required this.isAdmin, required this.isDisabled, required this.mustChangePassword, this.teamIds = const [],
      this.role = 'observer', this.playerId});

  factory StaffAccount.fromJson(Map<String, dynamic> j) => StaffAccount(
        id: j['id'] as String,
        email: j['email'] as String? ?? '',
        firstName: j['first_name'] as String?,
        lastName: j['last_name'] as String?,
        jobTitle: j['job_title'] as String?,
        isAdmin: j['is_admin'] == true,
        isDisabled: j['is_disabled'] == true,
        mustChangePassword: j['must_change_password'] == true,
        teamIds: [for (final t in (j['team_ids'] as List<dynamic>? ?? const <dynamic>[])) t as String],
        role: j['role'] as String? ?? 'observer',
        playerId: j['player_id'] as String?,
      );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? jobTitle;
  final bool isAdmin;
  final bool isDisabled;
  final bool mustChangePassword;
  /// Équipes dont le compte est membre (propriétaire, staff ou joueur).
  final List<String> teamIds;
  /// Rôle (core/permissions.dart) et, pour un compte joueur, le joueur relié.
  final String role;
  final String? playerId;

  String get displayName => [firstName, lastName].whereType<String>().join(' ').ifEmpty(email);
  String get initials => (firstName != null && lastName != null)
      ? '${firstName!.substring(0, 1)}${lastName!.substring(0, 1)}'.toUpperCase()
      : email.substring(0, 1).toUpperCase();
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository(ref.watch(supabaseProvider)));

final staffAccountsProvider = FutureProvider<List<StaffAccount>>((ref) async {
  final list = await ref.watch(adminRepositoryProvider)._call({'action': 'list'}) as List<dynamic>;
  return [for (final j in list) StaffAccount.fromJson(j as Map<String, dynamic>)]
    ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
});

/// Une équipe du projet, vue par l'administrateur (il n'en est pas forcément membre).
class AdminTeam {
  const AdminTeam({required this.id, required this.name, this.clubName, required this.category,
      required this.season, required this.createdBy});

  factory AdminTeam.fromJson(Map<String, dynamic> j) => AdminTeam(
        id: j['id'] as String,
        name: j['name'] as String,
        clubName: (j['club_name'] as String?)?.trim().isEmpty ?? true ? null : (j['club_name'] as String).trim(),
        category: j['category'] as String,
        season: j['season'] as String,
        createdBy: j['created_by'] as String,
      );

  final String id;
  final String name;
  final String? clubName;
  final String category;
  final String season;
  final String createdBy;
}

final adminTeamsProvider = FutureProvider<List<AdminTeam>>((ref) async {
  final list = await ref.watch(adminRepositoryProvider)._call({'action': 'list_teams'}) as List<dynamic>;
  return [for (final j in list) AdminTeam.fromJson(j as Map<String, dynamic>)];
});

/// Un joueur d'une équipe du projet (choix du joueur relié à un compte joueur).
class AdminPlayer {
  const AdminPlayer({required this.id, required this.teamId, required this.firstName, required this.lastName, this.shirtNumber});

  factory AdminPlayer.fromJson(Map<String, dynamic> j) => AdminPlayer(
        id: j['id'] as String,
        teamId: j['team_id'] as String,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String,
        shirtNumber: j['shirt_number'] as int?,
      );

  final String id;
  final String teamId;
  final String firstName;
  final String lastName;
  final int? shirtNumber;

  String get fullName => '$firstName $lastName';
}

final adminPlayersProvider = FutureProvider<List<AdminPlayer>>((ref) async {
  final list = await ref.watch(adminRepositoryProvider)._call({'action': 'list_players'}) as List<dynamic>;
  return [for (final j in list) AdminPlayer.fromJson(j as Map<String, dynamic>)];
});

/// Matrice de tous les rôles réglables : rôle → permission → autorisé.
final rolePermissionsProvider = FutureProvider<Map<String, Map<String, bool>>>((ref) async {
  final rows = await ref.watch(supabaseProvider).from('role_permissions').select('role, permission, allowed');
  final m = <String, Map<String, bool>>{};
  for (final r in rows) {
    (m[r['role'] as String] ??= {})[r['permission'] as String] = r['allowed'] as bool;
  }
  return m;
});

/// Exceptions d'un compte : permission → autorisé (true) ou interdit (false).
final accountPermissionsProvider = FutureProvider.family<Map<String, bool>, String>((ref, userId) async {
  final rows = await ref.watch(supabaseProvider).from('account_permissions').select('permission, allowed').eq('user_id', userId);
  return {for (final r in rows) r['permission'] as String: r['allowed'] as bool};
});

/// Appels à la fonction Edge `admin-users` (docs/01 §7.1). Toutes les actions demandent le réseau.
class AdminRepository {
  const AdminRepository(this._client);

  final SupabaseClient _client;

  /// Crée le compte et renvoie le mot de passe temporaire (affiché une seule fois).
  Future<String> create({required String email, required String firstName, required String lastName,
      required String jobTitle, required String role, String? playerId, List<String> teamIds = const []}) async {
    final r = await _call({
      'action': 'create', 'email': email, 'first_name': firstName, 'last_name': lastName,
      'job_title': jobTitle, 'role': role, 'player_id': playerId, 'team_ids': teamIds,
    }) as Map<String, dynamic>;
    return r['temporary_password'] as String;
  }

  Future<String> resetPassword(String userId) async {
    final r = await _call({'action': 'reset_password', 'user_id': userId}) as Map<String, dynamic>;
    return r['temporary_password'] as String;
  }

  /// Le compte devient « staff » exactement de ces équipes (celles dont il est propriétaire restent).
  Future<void> setTeams(String userId, List<String> teamIds) =>
      _call({'action': 'set_teams', 'user_id': userId, 'team_ids': teamIds});

  /// Rôle du compte ; un compte joueur est relié à [playerId] (il devient membre de son équipe).
  Future<void> setRole(String userId, String role, {String? playerId}) =>
      _call({'action': 'set_role', 'user_id': userId, 'role': role, 'player_id': playerId});

  /// Coche ou décoche une case de la matrice d'un rôle.
  Future<void> setRolePermission(String role, String permission, bool allowed) => _guard(() => _client
      .from('role_permissions')
      .upsert({'role': role, 'permission': permission, 'allowed': allowed, 'updated_at': DateTime.now().toUtc().toIso8601String()}));

  /// Exception d'un compte : true autorise, false interdit, null revient au rôle.
  Future<void> setAccountPermission(String userId, String permission, bool? allowed) => _guard(() => allowed == null
      ? _client.from('account_permissions').delete().eq('user_id', userId).eq('permission', permission)
      : _client.from('account_permissions').upsert({
          'user_id': userId, 'permission': permission, 'allowed': allowed,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }));

  Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on PostgrestException catch (e) {
      throw AppException('Erreur du serveur : ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(networkErrorMessage);
    }
  }

  Future<void> setDisabled(String userId, bool disabled) =>
      _call({'action': disabled ? 'disable' : 'enable', 'user_id': userId});

  Future<Object?> _call(Map<String, Object?> body) async {
    try {
      final r = await _client.functions.invoke('admin-users', body: body);
      return r.data;
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map ? details['error'] as String? : null;
      throw AppException(message ?? 'Erreur du serveur (${e.status}).');
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException(networkErrorMessage);
    }
  }
}
