import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../profile/profile_repository.dart';

/// E10 — Accueil. Pour l'instant : salutation et date ; séances, matchs et infirmerie arrivent
/// avec leurs modules.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider).value;
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(profile == null ? 'Bonjour' : 'Bonjour ${profile.firstName}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(today[0].toUpperCase() + today.substring(1), style: Theme.of(context).textTheme.titleMedium),
      ]),
    );
  }
}
