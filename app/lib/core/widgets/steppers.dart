import 'package:flutter/material.dart';

import '../../features/sessions/session_repository.dart';

/// Compteur − / + par pas de 5 minutes (specs §4.2 : éviter le clavier).
class MinutesStepper extends StatelessWidget {
  const MinutesStepper({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 240, this.step = 5});

  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          tooltip: 'Moins $step min',
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
        ),
        SizedBox(width: 64, child: Text('$value min', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
        IconButton(
          tooltip: 'Plus $step min',
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
        ),
      ]),
    );
  }
}

/// Puces RPE 0 à 10, colorées du vert au rouge ; le chiffre reste toujours affiché.
class RpeSelector extends StatelessWidget {
  const RpeSelector({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i <= 10; i++)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Tooltip(
              message: rpeLabels[i]!,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                // Un second appui sur la note choisie l'efface.
                onTap: () => onChanged(value == i ? null : i),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == i ? rpeColor(i) : rpeColor(i).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: rpeColor(i).withValues(alpha: value == i ? 1 : 0.35)),
                  ),
                  child: Text('$i',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: value == i ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      )),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}
