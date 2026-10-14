import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../features/team/team_repository.dart';
import '../photos.dart';
import '../theme.dart';

/// Carte joueur façon jeu de foot : numéro et poste en haut, photo, nom sur la bande blanche du
/// maillot du club, statistiques réelles en bas (jamais de note inventée). Grise si le joueur est blessé.
class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    this.stats = const [],
    this.injured = false,
    this.large = false,
    this.onTap,
    this.onLongPress,
  });

  final Player player;
  /// Lignes affichées sous le nom, ex. « 360′ · 3 B ».
  final List<String> stats;
  final bool injured;
  /// Grande carte de la fiche joueur.
  final bool large;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final bg = injured ? const Color(0xFF3A3A47) : clubRed;
    final band = injured ? const Color(0xFF55556A) : Colors.white;
    final nameColor = injured ? Colors.white : clubRed;
    final scale = large ? 1.6 : 1.0;
    final initial = player.firstName.isEmpty ? '' : '${player.firstName.substring(0, 1).toUpperCase()}. ';
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14 * scale),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10 * scale, 8 * scale, 10 * scale, 10 * scale),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(player.shirtNumber?.toString() ?? '–',
                    style: gameTitle(context, size: 26 * scale, color: Colors.white)),
                Text(player.positionCode, style: gameTitle(context, size: 15 * scale, color: Colors.white)),
              ]),
              const Spacer(),
              if (injured) Icon(Icons.healing, color: Colors.white, size: 18 * scale),
            ]),
            Transform.translate(
              offset: Offset(0, -10 * scale),
              child: Container(
                padding: EdgeInsets.all(2 * scale),
                decoration: const BoxDecoration(color: pitchBlack, shape: BoxShape.circle),
                child: PhotoAvatar(path: player.photoPath, initials: player.initials, radius: 26 * scale),
              ),
            ),
            Container(
              width: double.infinity,
              color: band,
              padding: EdgeInsets.symmetric(vertical: 3 * scale, horizontal: 4),
              child: Text(
                large ? player.fullName.toUpperCase() : '$initial${player.lastName}'.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: gameTitle(context, size: 16 * scale, color: nameColor),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              injured ? 'BLESSÉ' : (stats.isEmpty ? player.positionLabel : stats.join(' · ')),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: const Color(0xFFFFE1E3), fontSize: 13 * (large ? 1.2 : 1), fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ),
    );
  }
}
