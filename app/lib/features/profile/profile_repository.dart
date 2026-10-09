import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_repository.dart';

/// Fonctions du staff : valeur en base → libellé affiché.
const jobTitles = {
  'fitness_coach': 'Préparateur physique',
  'head_coach': 'Entraîneur',
  'assistant_coach': 'Entraîneur adjoint',
  'physio': 'Kinésithérapeute',
  'doctor': 'Médecin',
  'other': 'Autre',
};

class StaffProfile {
  const StaffProfile({required this.id, required this.firstName, required this.lastName,
      required this.jobTitle, this.phone});

  factory StaffProfile.fromJson(Map<String, dynamic> j) => StaffProfile(
        id: j['id'] as String,
        firstName: j['first_name'] as String,
        lastName: j['last_name'] as String,
        jobTitle: j['job_title'] as String,
        phone: j['phone'] as String?,
      );

  final String id;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String? phone;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.substring(0, 1)}${lastName.substring(0, 1)}'.toUpperCase();
}

/// Profil de l'utilisateur connecté (null s'il n'a pas encore été créé).
/// v1 : lu et écrit en ligne ; il passera par la base locale avec la synchronisation.
final myProfileProvider = FutureProvider<StaffProfile?>((ref) async {
  final client = ref.watch(supabaseProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  final row = await client.from('staff_profiles').select().eq('id', user.id).maybeSingle();
  return row == null ? null : StaffProfile.fromJson(row);
});

Future<void> saveMyProfile(WidgetRef ref, {required String firstName, required String lastName,
    required String jobTitle, String? phone}) async {
  final client = ref.read(supabaseProvider);
  try {
    await client.from('staff_profiles').upsert({
      'id': client.auth.currentUser!.id,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'job_title': jobTitle,
      'phone': (phone?.trim().isEmpty ?? true) ? null : phone!.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  } on PostgrestException catch (e) {
    throw AppException('Enregistrement impossible (${e.message}).');
  } catch (_) {
    throw const AppException(networkErrorMessage);
  }
  ref.invalidate(myProfileProvider);
}
