import 'package:flutter/material.dart';

/// Pastille « Blessé » : affichée partout tant qu'une blessure du joueur est en cours (specs E15).
class InjuredBadge extends StatelessWidget {
  const InjuredBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Text('Blessé', style: TextStyle(color: c.onErrorContainer, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
