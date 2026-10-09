import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import 'auth_repository.dart';

/// E01 — Connexion.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  int _failures = 0;

  bool get _filled => _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_filled || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(_email.text, _password.text);
      // La redirection du routeur prend le relais (Accueil ou nouveau mot de passe).
    } on AppException catch (e) {
      setState(() {
        _failures++;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormPage(children: [
      const SizedBox(height: 24),
      Icon(Icons.sports_soccer, size: 64, color: theme.colorScheme.primary),
      const SizedBox(height: 8),
      Text('PerfFoot', textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      Text('Suivi de la performance', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 32),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: const InputDecoration(labelText: 'Adresse e-mail'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      PasswordField(controller: _password, label: 'Mot de passe', onSubmitted: (_) => _submit()),
      if (_error != null) ...[
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
      ],
      const SizedBox(height: 24),
      ListenableBuilder(
        listenable: _password,
        builder: (_, _) => BusyButton(label: 'Se connecter', busy: _busy, onPressed: _filled ? _submit : null),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => context.push('/forgot-password'),
        child: Text('Mot de passe oublié ?',
            style: _failures >= 3 ? const TextStyle(fontWeight: FontWeight.bold) : null),
      ),
    ]);
  }
}

/// E02 — Mot de passe oublié : pas d'e-mail, réinitialisation par l'administrateur.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormPage(title: 'Mot de passe oublié', children: [
      const SizedBox(height: 24),
      Icon(Icons.key, size: 56, color: theme.colorScheme.primary),
      const SizedBox(height: 16),
      Text('Votre mot de passe est réinitialisé par l\'administrateur de l\'application.',
          textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      const Text(
        'Contactez-le : il vous communiquera un mot de passe temporaire, que vous remplacerez à la connexion.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      OutlinedButton(onPressed: () => context.pop(), child: const Text('Retour à la connexion')),
    ]);
  }
}

/// E03 — Nouveau mot de passe obligatoire après un mot de passe temporaire.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).setNewPassword(_password.text);
      if (mounted) showMessage(context, 'Mot de passe modifié');
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: FormPage(title: 'Nouveau mot de passe', automaticallyImplyLeading: false, children: [
        Card(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Vous vous êtes connecté avec un mot de passe temporaire. '
                'Pour votre sécurité, choisissez votre propre mot de passe.'),
          ),
        ),
        const SizedBox(height: 24),
        PasswordField(controller: _password, label: 'Nouveau mot de passe', validator: validateNewPassword),
        const SizedBox(height: 16),
        PasswordField(
          controller: _confirm,
          label: 'Confirmer le mot de passe',
          validator: (v) => v == _password.text ? null : 'Les deux mots de passe sont différents.',
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 8),
        const Text('8 caractères minimum, dont 1 chiffre'),
        const SizedBox(height: 24),
        BusyButton(label: 'Valider', busy: _busy, onPressed: _submit),
        TextButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: const Text('Se déconnecter'),
        ),
      ]),
    );
  }
}
