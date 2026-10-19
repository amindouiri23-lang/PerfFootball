import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/permissions.dart';
import '../auth/auth_repository.dart';
import 'team_filter.dart';
import 'team_repository.dart';
import 'team_screen.dart' show NoTeamScreen;

/// Membre du staff d'une équipe (fonction serveur team_staff, migration 20261022000001).
typedef StaffMember = ({String userId, String name, String role, bool owner, bool disabled});

/// Staff de l'équipe : lu en ligne (les profils du staff ne sont pas sur l'appareil).
final teamStaffProvider = FutureProvider.family<List<StaffMember>, String>((ref, teamId) async {
  try {
    final rows = await ref.watch(supabaseProvider).rpc<List<dynamic>>('team_staff', params: {'p_team_id': teamId});
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          userId: r['user_id'] as String,
          name: [r['first_name'], r['last_name']].whereType<String>().join(' ').trim(),
          role: r['app_role'] as String,
          owner: r['member_role'] == 'owner',
          disabled: r['disabled'] == true,
        ),
    ];
  } catch (_) {
    throw const AppException(networkErrorMessage);
  }
});

/// Staff de l'équipe active : chaque compte affecté à l'équipe, avec son rôle.
class TeamStaffScreen extends ConsumerWidget {
  const TeamStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(activeTeamProvider).value;
    if (team == null) return const NoTeamScreen();
    final staff = ref.watch(teamStaffProvider(team.id));
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Staff'), bottom: teamFilterBar(ref)),
      body: staff.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(e is AppException ? e.message : networkErrorMessage),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.invalidate(teamStaffProvider(team.id)), child: const Text('Réessayer')),
          ]),
        ),
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.refresh(teamStaffProvider(team.id).future),
          child: ListView(children: [
            ListTile(
              title: Text('${team.name} · ${list.length} membre${list.length > 1 ? 's' : ''} du staff'),
              subtitle: const Text('Les comptes sont affectés aux équipes par l\'administrateur (Profil → Administration).'),
            ),
            for (final m in list)
              ListTile(
                enabled: !m.disabled,
                leading: CircleAvatar(
                  child: Text(m.name.isEmpty ? '?' : m.name.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join().toUpperCase()),
                ),
                title: Text(m.name.isEmpty ? 'Compte sans nom' : m.name),
                subtitle: Text([
                  roleLabels[m.role] ?? m.role,
                  if (m.owner) 'responsable de l\'équipe',
                  if (m.disabled) 'compte désactivé',
                ].join(' · ')),
                trailing: Icon(_roleIcon(m.role), color: theme.colorScheme.primary),
              ),
          ]),
        ),
      ),
    );
  }

  IconData _roleIcon(String role) => switch (role) {
        'admin' => Icons.admin_panel_settings_outlined,
        'technical_director' => Icons.workspace_premium_outlined,
        'head_coach' || 'assistant_coach' => Icons.sports,
        'fitness_coach' => Icons.fitness_center,
        'medical' => Icons.medical_services_outlined,
        _ => Icons.visibility_outlined,
      };
}
