import 'package:flutter/material.dart';

/// Onglet pas encore développé : la navigation existe déjà, l'écran arrive dans une prochaine étape.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Bientôt disponible')),
    );
  }
}
