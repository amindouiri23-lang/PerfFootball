import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/router.dart';
import '../../core/widgets/form_page.dart';
import '../../data/database.dart';
import '../../data/sync.dart';
import '../sessions/session_repository.dart' show isoDate;
import 'team_repository.dart';

// Dossier du joueur (specs E35 à E38) : une ligne par joueur et par dossier, id = id du joueur.

const consentBy = {'player': 'Le joueur', 'guardian': 'Un parent ou tuteur'};

/// Longueurs maximales du dossier administratif (contraintes de la base).
const profileMaxLength = {
  'nationality': 60, 'birthPlace': 80, 'phone': 30, 'email': 120, 'address': 200, 'school': 120, 'schoolYear': 80,
  'fatherName': 80, 'fatherNationality': 60, 'fatherOccupation': 80, 'fatherMaritalStatus': 40, 'motherName': 80,
  'motherNationality': 60, 'motherMaritalStatus': 40, 'previousClub': 80, 'previousClubCity': 80,
  'preferredRole': 80, 'remarks': 1000, 'otherPosition': 80, 'schoolAddress': 200, 'coachName': 80, 'managerName': 160,
};

/// Coupe un texte à la longueur acceptée par la base.
String? fitLength(String? s, int max) => s == null || s.length <= max ? s : s.substring(0, max);

final playerProfileProvider = StreamProvider.family<PlayerProfile?, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.playerProfiles)..where((p) => p.id.equals(playerId) & p.deleted.equals(false))).watchSingleOrNull();
});

final playerMedicalProvider = StreamProvider.family<MedicalRecord?, String>((ref, playerId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.playerMedical)..where((m) => m.id.equals(playerId) & m.deleted.equals(false))).watchSingleOrNull();
});

final playerFilesRepositoryProvider = Provider<PlayerFilesRepository>((ref) => PlayerFilesRepository(ref));

class PlayerFilesRepository {
  PlayerFilesRepository(this._ref);

  final Ref _ref;

  AppDatabase get _db => _ref.read(databaseProvider);

  Future<void> saveProfile(PlayerProfilesCompanion fields, {required String teamId, required String playerId}) async {
    final now = nowIso();
    final existing = await (_db.select(_db.playerProfiles)..where((p) => p.id.equals(playerId))).getSingleOrNull();
    await _db.into(_db.playerProfiles).insertOnConflictUpdate(fields.copyWith(
          id: Value(playerId), teamId: Value(teamId), playerId: Value(playerId), deleted: const Value(false),
          createdAt: Value(existing?.createdAt ?? now), updatedAt: Value(now), isDirty: const Value(true),
        ));
    _ref.read(syncControllerProvider.notifier).requestSync();
  }

  Future<void> saveMedical(PlayerMedicalCompanion fields, {required String teamId, required String playerId}) async {
    final now = nowIso();
    final existing = await (_db.select(_db.playerMedical)..where((m) => m.id.equals(playerId))).getSingleOrNull();
    await _db.into(_db.playerMedical).insertOnConflictUpdate(fields.copyWith(
          id: Value(playerId), teamId: Value(teamId), playerId: Value(playerId), deleted: const Value(false),
          createdAt: Value(existing?.createdAt ?? now), updatedAt: Value(now), isDirty: const Value(true),
        ));
    _ref.read(syncControllerProvider.notifier).requestSync();
  }
}

String? _clean(String text) => text.trim().isEmpty ? null : text.trim();

// ---------------------------------------------------------------------------
// Onglets de la fiche joueur
// ---------------------------------------------------------------------------

Widget _fields(BuildContext context, List<(String, String?)> rows) {
  final filled = rows.where((r) => r.$2 != null && r.$2!.isNotEmpty);
  return Column(children: [
    for (final r in filled)
      ListTile(dense: true, title: Text(r.$1, style: Theme.of(context).textTheme.bodySmall), subtitle: Text(r.$2!,
          style: Theme.of(context).textTheme.bodyLarge)),
  ]);
}

/// E35 — Onglet « Dossier » : informations administratives et familiales.
class PlayerProfileTab extends ConsumerWidget {
  const PlayerProfileTab({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProfileProvider(player.id)).value;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      if (ref.watch(permsProvider).can('dossier.edit'))
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/team/players/${player.id}/profile'),
            icon: Icon(p == null ? Icons.add : Icons.edit_outlined),
            label: Text(p == null ? 'Remplir le dossier' : 'Modifier le dossier'),
          ),
        ),
      ),
      if (p == null)
        const Padding(padding: EdgeInsets.all(16), child: Text('Dossier vide.'))
      else
        _fields(context, [
          ('Nationalité', p.nationality),
          ('Lieu de naissance', p.birthPlace),
          ('Téléphone', p.phone),
          ('E-mail', p.email),
          ('Adresse', p.address),
          ('Établissement scolaire', p.school),
          ("Adresse de l'établissement", p.schoolAddress),
          ('Année scolaire', p.schoolYear),
          ('Père', [p.fatherName, p.fatherNationality, p.fatherOccupation, p.fatherMaritalStatus].whereType<String>().join(' · ')),
          ('Mère', [p.motherName, p.motherNationality, p.motherMaritalStatus].whereType<String>().join(' · ')),
          ('Club précédent', [p.previousClub, p.previousClubCity].whereType<String>().join(' · ')),
          ('Années de formation', p.yearsTraining?.toString()),
          ('Rôle préféré', p.preferredRole),
          ('Autre poste', p.otherPosition),
          ('Entraîneur', p.coachName),
          ('Responsable / manager', p.managerName),
          ('Remarques', p.remarks),
        ]),
    ]);
  }
}

/// E37 — Onglet « Médical » : visible avec la permission « Dossier médical — Voir ».
class PlayerMedicalTab extends ConsumerWidget {
  const PlayerMedicalTab({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permsProvider);
    if (!perms.can('medical.view')) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Votre rôle ne permet pas de voir le dossier médical.', textAlign: TextAlign.center),
        ),
      );
    }
    final m = ref.watch(playerMedicalProvider(player.id)).value;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      if (perms.can('medical.edit'))
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/team/players/${player.id}/medical'),
            icon: Icon(m == null ? Icons.add : Icons.edit_outlined),
            label: Text(m == null ? 'Créer le dossier médical' : 'Modifier le dossier médical'),
          ),
        ),
      ),
      if (m == null)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucun dossier médical. Sa création demande le consentement du joueur, ou d\'un parent s\'il est mineur.'),
        )
      else ...[
        ListTile(
          dense: true,
          leading: const Icon(Icons.verified_user_outlined),
          title: Text('Consentement : ${consentBy[m.consentBy]!.toLowerCase()}'),
          subtitle: Text('le ${DateFormat('d MMMM y', 'fr_FR').format(DateTime.parse(m.consentDate))}'),
        ),
        _fields(context, [
          ('Allergies', m.allergies),
          ('Maladies ou conditions connues', m.conditions),
          ('Tension basse, malaises, anxiété', m.lowBpAnxiety),
          ('Interventions chirurgicales', m.surgeries),
          ('Blessures des 12 derniers mois', m.recentInjuries),
          ('Remarques', m.remarks),
        ]),
      ],
    ]);
  }
}

// ---------------------------------------------------------------------------
// Formulaires
// ---------------------------------------------------------------------------

/// E36 — Dossier administratif.
class PlayerProfileFormScreen extends ConsumerStatefulWidget {
  const PlayerProfileFormScreen({super.key, required this.playerId});

  final String playerId;

  @override
  ConsumerState<PlayerProfileFormScreen> createState() => _PlayerProfileFormScreenState();
}

class _PlayerProfileFormScreenState extends ConsumerState<PlayerProfileFormScreen> {
  static const _keys = [
    'nationality', 'birthPlace', 'phone', 'email', 'address', 'school', 'schoolYear',
    'fatherName', 'fatherNationality', 'fatherOccupation', 'fatherMaritalStatus',
    'motherName', 'motherNationality', 'motherMaritalStatus', 'previousClub', 'previousClubCity',
    'yearsTraining', 'preferredRole', 'remarks', 'otherPosition', 'schoolAddress', 'coachName', 'managerName',
  ];
  final _c = {for (final k in _keys) k: TextEditingController()};
  bool _loaded = false;
  bool _saving = false;

  void _load(PlayerProfile? p) {
    if (_loaded) return;
    _loaded = true;
    if (p == null) return;
    final v = <String, String?>{
      'nationality': p.nationality, 'birthPlace': p.birthPlace, 'phone': p.phone, 'email': p.email,
      'address': p.address, 'school': p.school, 'schoolYear': p.schoolYear, 'fatherName': p.fatherName,
      'fatherNationality': p.fatherNationality, 'fatherOccupation': p.fatherOccupation,
      'fatherMaritalStatus': p.fatherMaritalStatus, 'motherName': p.motherName,
      'motherNationality': p.motherNationality, 'motherMaritalStatus': p.motherMaritalStatus,
      'previousClub': p.previousClub, 'previousClubCity': p.previousClubCity,
      'yearsTraining': p.yearsTraining?.toString(), 'preferredRole': p.preferredRole, 'remarks': p.remarks,
      'otherPosition': p.otherPosition, 'schoolAddress': p.schoolAddress, 'coachName': p.coachName,
      'managerName': p.managerName,
    };
    for (final k in _keys) {
      _c[k]!.text = v[k] ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(Player player) async {
    if (_saving) return;
    _saving = true;
    try {
      String? v(String k) => _clean(_c[k]!.text);
      await ref.read(playerFilesRepositoryProvider).saveProfile(
            PlayerProfilesCompanion(
              nationality: Value(v('nationality')), birthPlace: Value(v('birthPlace')), phone: Value(v('phone')),
              email: Value(v('email')), address: Value(v('address')), school: Value(v('school')),
              schoolYear: Value(v('schoolYear')), fatherName: Value(v('fatherName')),
              fatherNationality: Value(v('fatherNationality')), fatherOccupation: Value(v('fatherOccupation')),
              fatherMaritalStatus: Value(v('fatherMaritalStatus')), motherName: Value(v('motherName')),
              motherNationality: Value(v('motherNationality')), motherMaritalStatus: Value(v('motherMaritalStatus')),
              previousClub: Value(v('previousClub')), previousClubCity: Value(v('previousClubCity')),
              yearsTraining: Value(int.tryParse(_c['yearsTraining']!.text)), preferredRole: Value(v('preferredRole')),
              remarks: Value(v('remarks')), otherPosition: Value(v('otherPosition')),
              schoolAddress: Value(v('schoolAddress')), coachName: Value(v('coachName')),
              managerName: Value(v('managerName')),
            ),
            teamId: player.teamId,
            playerId: player.id,
          );
      if (!mounted) return;
      showMessage(context, 'Dossier enregistré');
      context.go(ref.read(permsProvider).isPlayer ? '/home' : '/team/players/${player.id}');
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 600), () => _saving = false);
    }
  }

  Widget _field(String key, String label, {TextInputType? keyboard, int lines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _c[key],
          keyboardType: keyboard,
          maxLines: lines,
          maxLength: profileMaxLength[key],
          inputFormatters: keyboard == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
          textCapitalization: keyboard == null ? TextCapitalization.sentences : TextCapitalization.none,
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider(widget.playerId)).value;
    final profile = ref.watch(playerProfileProvider(widget.playerId));
    if (player == null || profile.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _load(profile.value);
    final theme = Theme.of(context);
    Widget section(String t) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(t, style: theme.textTheme.titleSmall),
        );
    return FormPage(title: 'Dossier — ${player.fullName}', children: [
      section('Identité et contact'),
      _field('nationality', 'Nationalité'),
      _field('birthPlace', 'Lieu de naissance'),
      _field('phone', 'Téléphone', keyboard: TextInputType.phone),
      _field('email', 'E-mail', keyboard: TextInputType.emailAddress),
      _field('address', 'Adresse', lines: 2),
      section('Scolarité'),
      _field('school', 'Établissement scolaire'),
      _field('schoolYear', 'Année scolaire'),
      _field('schoolAddress', "Adresse de l'établissement", lines: 2),
      section('Parents'),
      _field('fatherName', 'Nom du père'),
      _field('fatherNationality', 'Nationalité du père'),
      _field('fatherOccupation', 'Profession du père'),
      _field('fatherMaritalStatus', 'Situation familiale du père'),
      _field('motherName', 'Nom de la mère'),
      _field('motherNationality', 'Nationalité de la mère'),
      _field('motherMaritalStatus', 'Situation familiale de la mère'),
      section('Parcours'),
      _field('previousClub', 'Club précédent'),
      _field('previousClubCity', 'Ville du club précédent'),
      _field('yearsTraining', 'Années de formation', keyboard: TextInputType.number),
      _field('preferredRole', 'Rôle préféré'),
      _field('otherPosition', 'Autre poste'),
      _field('coachName', 'Entraîneur'),
      _field('managerName', 'Responsable / manager'),
      _field('remarks', 'Remarques', lines: 3),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => _save(player), child: const Text('Enregistrer')),
    ]);
  }
}

/// E38 — Dossier médical : le consentement est demandé avant toute saisie.
class PlayerMedicalFormScreen extends ConsumerStatefulWidget {
  const PlayerMedicalFormScreen({super.key, required this.playerId});

  final String playerId;

  @override
  ConsumerState<PlayerMedicalFormScreen> createState() => _PlayerMedicalFormScreenState();
}

class _PlayerMedicalFormScreenState extends ConsumerState<PlayerMedicalFormScreen> {
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _lowBp = TextEditingController();
  final _surgeries = TextEditingController();
  final _injuries = TextEditingController();
  final _remarks = TextEditingController();
  String? _consentBy;
  DateTime _consentDate = DateTime.now();
  bool _attested = false;
  bool _loaded = false;
  bool _submitted = false;
  bool _saving = false;

  void _load(MedicalRecord? m) {
    if (_loaded) return;
    _loaded = true;
    if (m == null) return;
    _consentBy = m.consentBy;
    _consentDate = DateTime.parse(m.consentDate);
    _attested = true;
    _allergies.text = m.allergies ?? '';
    _conditions.text = m.conditions ?? '';
    _lowBp.text = m.lowBpAnxiety ?? '';
    _surgeries.text = m.surgeries ?? '';
    _injuries.text = m.recentInjuries ?? '';
    _remarks.text = m.remarks ?? '';
  }

  @override
  void dispose() {
    for (final c in [_allergies, _conditions, _lowBp, _surgeries, _injuries, _remarks]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(Player player) async {
    setState(() => _submitted = true);
    if (_consentBy == null || !_attested || _saving) return;
    _saving = true;
    try {
      await ref.read(playerFilesRepositoryProvider).saveMedical(
            PlayerMedicalCompanion(
              consentDate: Value(isoDate(_consentDate)), consentBy: Value(_consentBy!),
              allergies: Value(_clean(_allergies.text)), conditions: Value(_clean(_conditions.text)),
              lowBpAnxiety: Value(_clean(_lowBp.text)), surgeries: Value(_clean(_surgeries.text)),
              recentInjuries: Value(_clean(_injuries.text)), remarks: Value(_clean(_remarks.text)),
            ),
            teamId: player.teamId,
            playerId: player.id,
          );
      if (!mounted) return;
      showMessage(context, 'Dossier médical enregistré');
      context.go('/team/players/${player.id}');
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 600), () => _saving = false);
    }
  }

  Widget _area(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: 2,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label, hintText: 'Non, ou précisez'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider(widget.playerId)).value;
    final medical = ref.watch(playerMedicalProvider(widget.playerId));
    if (player == null || medical.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!ref.watch(permsProvider).can('medical.edit')) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Votre rôle ne permet pas de modifier le dossier médical.')),
      );
    }
    _load(medical.value);
    final theme = Theme.of(context);
    final consentMissing = _submitted && (_consentBy == null || !_attested);
    return FormPage(title: 'Dossier médical — ${player.fullName}', children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Consentement *', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            const Text('Données de santé : à recueillir auprès du joueur, ou d\'un parent ou tuteur s\'il est mineur.'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final e in consentBy.entries)
                ChoiceChip(label: Text(e.value), selected: _consentBy == e.key, onSelected: (_) => setState(() => _consentBy = e.key)),
            ]),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _consentDate,
                    firstDate: DateTime(2020), lastDate: DateTime.now());
                if (d != null) setState(() => _consentDate = d);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date du consentement', suffixIcon: Icon(Icons.calendar_today)),
                child: Text(DateFormat('d MMMM y', 'fr_FR').format(_consentDate)),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _attested,
              onChanged: (v) => setState(() => _attested = v ?? false),
              title: const Text('J\'atteste avoir recueilli ce consentement'),
            ),
            if (consentMissing)
              Text('Le consentement est obligatoire.', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      _area(_allergies, 'Allergies (aliments, insectes, médicaments…)'),
      _area(_conditions, 'Maladie ou condition connue (asthme, épilepsie, diabète…)'),
      _area(_lowBp, 'Tension basse, malaises, anxiété'),
      _area(_surgeries, 'Interventions chirurgicales (et quand)'),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _injuries,
          maxLines: 3,
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Blessures des 12 derniers mois (nature, période)'),
        ),
      ),
      _area(_remarks, 'Remarques'),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => _save(player), child: const Text('Enregistrer')),
    ]);
  }
}
