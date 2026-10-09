import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_repository.dart';

class StaffAccount {
  const StaffAccount({required this.id, required this.email, this.firstName, this.lastName, this.jobTitle,
      required this.isAdmin, required this.isDisabled, required this.mustChangePassword});

  factory StaffAccount.fromJson(Map<String, dynamic> j) => StaffAccount(
        id: j['id'] as String,
        email: j['email'] as String? ?? '',
        firstName: j['first_name'] as String?,
        lastName: j['last_name'] as String?,
        jobTitle: j['job_title'] as String?,
        isAdmin: j['is_admin'] == true,
        isDisabled: j['is_disabled'] == true,
        mustChangePassword: j['must_change_password'] == true,
      );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? jobTitle;
  final bool isAdmin;
  final bool isDisabled;
  final bool mustChangePassword;

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

/// Appels à la fonction Edge `admin-users` (docs/01 §7.1). Toutes les actions demandent le réseau.
class AdminRepository {
  const AdminRepository(this._client);

  final SupabaseClient _client;

  /// Crée le compte et renvoie le mot de passe temporaire (affiché une seule fois).
  Future<String> create({required String email, required String firstName, required String lastName,
      required String jobTitle, required bool isAdmin}) async {
    final r = await _call({
      'action': 'create', 'email': email, 'first_name': firstName, 'last_name': lastName,
      'job_title': jobTitle, 'is_admin': isAdmin,
    }) as Map<String, dynamic>;
    return r['temporary_password'] as String;
  }

  Future<String> resetPassword(String userId) async {
    final r = await _call({'action': 'reset_password', 'user_id': userId}) as Map<String, dynamic>;
    return r['temporary_password'] as String;
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
