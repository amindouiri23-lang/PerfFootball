import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../auth/auth_repository.dart';
import 'profile_repository.dart';

/// E04 — Mon profil.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final profile = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil'), actions: [
        IconButton(tooltip: 'Modifier', icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/profile/edit')),
      ]),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [
        profile.when(
          loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
          error: (_, _) => const ListTile(leading: Icon(Icons.cloud_off), title: Text(networkErrorMessage)),
          data: (p) => Column(children: [
            CircleAvatar(radius: 40, child: Text(p?.initials ?? '?', style: theme.textTheme.headlineSmall)),
            const SizedBox(height: 12),
            Text(p?.fullName ?? 'Profil à compléter', style: theme.textTheme.titleLarge),
            Text(jobTitles[p?.jobTitle] ?? '', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (p?.phone != null) ListTile(leading: const Icon(Icons.phone_outlined), title: Text(p!.phone!)),
          ]),
        ),
        ListTile(leading: const Icon(Icons.mail_outline), title: Text(user?.email ?? ''), subtitle: const Text('E-mail')),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Changer le mot de passe'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile/password'),
        ),
        if (user?.isAdmin ?? false)
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Administration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/profile/admin'),
          ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            // Pas encore de données locales : la vérification « données non synchronisées »
            // arrivera avec la synchronisation.
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ),
      ]),
    );
  }
}

/// E04 — modification du profil.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final StaffProfile? _initial = ref.read(myProfileProvider).value;
  late final _first = TextEditingController(text: _initial?.firstName);
  late final _last = TextEditingController(text: _initial?.lastName);
  late final _phone = TextEditingController(text: _initial?.phone);
  late String? _job = _initial?.jobTitle;
  bool _busy = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await saveMyProfile(ref, firstName: _first.text, lastName: _last.text, jobTitle: _job!, phone: _phone.text);
      if (!mounted) return;
      showMessage(context, 'Profil mis à jour');
      context.go('/profile');
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
    _phone.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatoire' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: FormPage(title: 'Modifier mon profil', children: [
        TextFormField(controller: _first, decoration: const InputDecoration(labelText: 'Prénom *'), validator: _required),
        const SizedBox(height: 16),
        TextFormField(controller: _last, decoration: const InputDecoration(labelText: 'Nom *'), validator: _required),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _job,
          decoration: const InputDecoration(labelText: 'Fonction *'),
          items: [for (final e in jobTitles.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          onChanged: (v) => setState(() => _job = v),
          validator: (v) => v == null ? 'Obligatoire' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone')),
        const SizedBox(height: 24),
        BusyButton(label: 'Enregistrer', busy: _busy, onPressed: _save),
      ]),
    );
  }
}

/// E05 — Changer le mot de passe.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(_current.text, _next.text);
      if (!mounted) return;
      showMessage(context, 'Mot de passe modifié');
      context.go('/profile');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: FormPage(title: 'Changer le mot de passe', children: [
        PasswordField(controller: _current, label: 'Mot de passe actuel',
            validator: (v) => (v ?? '').isEmpty ? 'Obligatoire' : null),
        const SizedBox(height: 16),
        PasswordField(
          controller: _next,
          label: 'Nouveau mot de passe',
          validator: (v) => validateNewPassword(v) ??
              (v == _current.text ? 'Le nouveau mot de passe doit être différent de l\'actuel.' : null),
        ),
        const SizedBox(height: 16),
        PasswordField(
          controller: _confirm,
          label: 'Confirmer le mot de passe',
          validator: (v) => v == _next.text ? null : 'Les deux mots de passe sont différents.',
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 8),
        const Text('8 caractères minimum, dont 1 chiffre'),
        const SizedBox(height: 24),
        BusyButton(label: 'Enregistrer', busy: _busy, onPressed: _save),
      ]),
    );
  }
}
