import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Utilisateur connecté, mis à jour à chaque connexion, déconnexion ou modification du compte.
final currentUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange.map((s) => s.session?.user),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseProvider)),
);

/// Message d'erreur affichable à l'utilisateur (déjà en français).
class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

const networkErrorMessage = 'Une connexion internet est nécessaire.';

extension StaffUser on User {
  bool get isAdmin => appMetadata['role'] == 'admin';
  bool get mustChangePassword => userMetadata?['must_change_password'] == true;
}

/// Connexion Supabase Auth. Pas d'inscription ni d'e-mail : les comptes et les mots de passe
/// temporaires viennent de l'administrateur (docs/01 §7.1).
class AuthRepository extends ChangeNotifier {
  AuthRepository(this._client) {
    _subscription = _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _subscription;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _guard(() => _client.auth.signInWithPassword(email: email.trim(), password: password));

  Future<void> signOut() => _client.auth.signOut();

  /// Remplace un mot de passe temporaire (E03) et lève l'obligation de le changer.
  Future<void> setNewPassword(String password) => _guard(() => _client.auth.updateUser(
        UserAttributes(password: password, data: {'must_change_password': false}),
      ));

  /// Changement volontaire (E05) : le mot de passe actuel est vérifié par une reconnexion.
  Future<void> changePassword(String current, String next) => _guard(() async {
        final email = currentUser!.email!;
        try {
          await _client.auth.signInWithPassword(email: email, password: current);
        } on AuthException catch (e) {
          if (e.code == 'invalid_credentials') throw const AppException('Mot de passe actuel incorrect.');
          rethrow;
        }
        return _client.auth.updateUser(UserAttributes(password: next));
      });

  Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(_authMessage(e));
    } catch (e) {
      if (e is AuthRetryableFetchException || e.toString().contains('SocketException') ||
          e.toString().contains('ClientException')) {
        throw const AppException(networkErrorMessage);
      }
      rethrow;
    }
  }

  static String _authMessage(AuthException e) => switch (e.code) {
        'invalid_credentials' => 'E-mail ou mot de passe incorrect.',
        'user_banned' => 'Ce compte est désactivé. Contactez l\'administrateur.',
        'same_password' => 'Le nouveau mot de passe doit être différent de l\'actuel.',
        'weak_password' => '8 caractères minimum, dont 1 chiffre.',
        _ when e is AuthRetryableFetchException => networkErrorMessage,
        _ => 'Erreur de connexion (${e.message}).',
      };

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Règle commune aux écrans E03 et E05 : 8 caractères minimum, dont 1 chiffre.
String? validateNewPassword(String? value) {
  final v = value ?? '';
  if (v.length < 8 || !v.contains(RegExp(r'\d'))) return '8 caractères minimum, dont 1 chiffre.';
  return null;
}
