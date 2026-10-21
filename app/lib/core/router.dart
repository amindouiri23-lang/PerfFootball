import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_screens.dart';
import '../features/admin/player_accounts_screen.dart';
import '../features/admin/roles_screens.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_screens.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screens.dart';
import '../features/injuries/injuries_screen.dart';
import '../features/matches/end_match_screen.dart';
import '../features/matches/club_results_screen.dart';
import '../features/matches/lineup_screen.dart';
import '../features/matches/match_form_screen.dart';
import '../features/matches/match_screen.dart';
import '../features/matches/matches_list_screen.dart';
import '../features/matches/squad_screen.dart';
import '../features/sessions/attendance_screen.dart';
import '../features/sessions/closing_screen.dart';
import '../features/sessions/injury_form_screen.dart';
import '../features/sessions/player_load_screen.dart';
import '../features/sessions/session_form_screen.dart';
import '../features/sessions/session_screen.dart';
import '../features/sessions/sessions_list_screen.dart';
import '../features/sessions/wellness_screens.dart';
import '../features/import/import_screen.dart';
import '../features/team/club_players_screen.dart';
import '../features/team/player_files.dart';
import '../features/team/team_staff_screen.dart';
import '../features/team/player_screens.dart';
import '../features/tactics/tactic_screens.dart';
import '../features/tests/test_screens.dart';
import '../features/wellness/wellness_survey_screens.dart';
import '../features/team/team_form_screen.dart';
import '../features/team/team_screen.dart';
import 'permissions.dart';
import 'widgets/app_shell.dart';
import 'widgets/sync_indicator.dart';

const _publicRoutes = {'/login', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final user = auth.currentUser;
      final location = state.matchedLocation;
      if (user == null) return _publicRoutes.contains(location) ? null : '/login';
      if (user.mustChangePassword) return location == '/new-password' ? null : '/new-password';
      if (_publicRoutes.contains(location) || location == '/new-password') return '/home';
      if (location.startsWith('/profile/admin') && !user.isAdmin) return '/profile';
      final perms = ref.read(permsProvider);
      if (perms.isPlayer) return _playerRoutes.hasMatch(location) ? null : '/home';
      final need = requiredPermission(location);
      if (need != null && !perms.can(need)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/new-password', builder: (_, _) => const NewPasswordScreen()),
      GoRoute(path: '/sync', builder: (_, _) => const SyncScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const HomeScreen(),
              routes: [
                // Résultats de toutes les équipes du club, en lecture seule (staff et joueurs).
                GoRoute(path: 'results', builder: (_, _) => const ClubResultsScreen()),
                // Charge de la semaine par joueur (RPE × durée).
                GoRoute(path: 'load', builder: (_, _) => const PlayerLoadScreen()),
                // Espace joueur : son dossier et ses questionnaires de bien-être.
                GoRoute(path: 'dossier/:playerId', builder: (_, s) => PlayerProfileFormScreen(playerId: s.pathParameters['playerId']!)),
                GoRoute(
                  path: 'wellness/:sessionId/:playerId',
                  builder: (_, s) => WellnessFormScreen(
                    sessionId: s.pathParameters['sessionId']!,
                    playerId: s.pathParameters['playerId']!,
                    single: true,
                  ),
                ),
                GoRoute(
                  path: 'survey/:surveyId/:playerId',
                  builder: (_, s) => WellnessFormScreen(
                    surveyId: s.pathParameters['surveyId']!,
                    playerId: s.pathParameters['playerId']!,
                    single: true,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/sessions',
              builder: (_, _) => const SessionsListScreen(),
              routes: [
                GoRoute(path: 'new', builder: (_, _) => const SessionFormScreen()),
                // Questionnaires de bien-être lancés seuls (avant « :id », qui sinon les capterait).
                GoRoute(
                  path: 'wellness',
                  builder: (_, _) => const SurveysScreen(),
                  routes: [
                    GoRoute(path: 'new', builder: (_, _) => const NewSurveyScreen()),
                    GoRoute(
                      path: ':surveyId',
                      builder: (_, s) => SurveyScreen(id: s.pathParameters['surveyId']!),
                      routes: [
                        GoRoute(
                          path: ':playerId',
                          builder: (_, s) => WellnessFormScreen(
                            key: ValueKey(s.pathParameters['playerId']),
                            surveyId: s.pathParameters['surveyId']!,
                            playerId: s.pathParameters['playerId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, s) => SessionScreen(id: s.pathParameters['id']!),
                  routes: [
                    GoRoute(path: 'edit', builder: (_, s) => SessionFormScreen(id: s.pathParameters['id'])),
                    GoRoute(path: 'attendance', builder: (_, s) => AttendanceScreen(sessionId: s.pathParameters['id']!)),
                    GoRoute(path: 'close', builder: (_, s) => ClosingScreen(sessionId: s.pathParameters['id']!)),
                    GoRoute(path: 'tactic/:tid', builder: (_, s) => TacticEditorScreen(id: s.pathParameters['tid']!)),
                    GoRoute(
                      path: 'injury/:playerId',
                      builder: (_, s) =>
                          InjuryFormScreen(sessionId: s.pathParameters['id']!, playerId: s.pathParameters['playerId']!),
                    ),
                    GoRoute(
                      path: 'wellness',
                      builder: (_, s) => WellnessListScreen(sessionId: s.pathParameters['id']!),
                      routes: [
                        GoRoute(
                          path: ':playerId',
                          // Clé par joueur : « joueur suivant » doit repartir d'un questionnaire vierge.
                          builder: (_, s) => WellnessFormScreen(
                            key: ValueKey(s.pathParameters['playerId']),
                            sessionId: s.pathParameters['id']!,
                            playerId: s.pathParameters['playerId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/matches',
              builder: (_, _) => const MatchesListScreen(),
              routes: [
                GoRoute(path: 'new', builder: (_, _) => const MatchFormScreen()),
                GoRoute(
                  path: ':id',
                  builder: (_, s) => MatchScreen(id: s.pathParameters['id']!),
                  routes: [
                    GoRoute(path: 'edit', builder: (_, s) => MatchFormScreen(id: s.pathParameters['id'])),
                    GoRoute(path: 'squad', builder: (_, s) => SquadScreen(matchId: s.pathParameters['id']!)),
                    GoRoute(path: 'lineup', builder: (_, s) => LineupScreen(matchId: s.pathParameters['id']!)),
                    GoRoute(path: 'tactic/:tid', builder: (_, s) => TacticEditorScreen(id: s.pathParameters['tid']!)),
                    GoRoute(
                      path: 'end',
                      builder: (_, s) => EndMatchScreen(
                          matchId: s.pathParameters['id']!, abandoned: s.uri.queryParameters['abandoned'] == '1'),
                    ),
                    GoRoute(
                      path: 'injury/:playerId',
                      builder: (_, s) =>
                          InjuryFormScreen(matchId: s.pathParameters['id']!, playerId: s.pathParameters['playerId']!),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/team',
              builder: (_, _) => const TeamScreen(),
              routes: [
                GoRoute(path: 'new', builder: (_, _) => const TeamFormScreen()),
                GoRoute(path: 'edit', builder: (_, _) => const TeamFormScreen(editActive: true)),
                GoRoute(path: 'players/new', builder: (_, _) => const PlayerFormScreen()),
                GoRoute(path: 'players/club', builder: (_, _) => const ClubPlayersScreen()),
                GoRoute(path: 'staff', builder: (_, _) => const TeamStaffScreen()),
                GoRoute(path: 'import', builder: (_, _) => const ImportScreen()),
                GoRoute(
                  path: 'tactics',
                  builder: (_, _) => const TacticsListScreen(),
                  routes: [GoRoute(path: ':tid', builder: (_, s) => TacticEditorScreen(id: s.pathParameters['tid']!))],
                ),
                GoRoute(
                  path: 'tests',
                  builder: (_, _) => const TestDaysScreen(),
                  routes: [GoRoute(path: ':date', builder: (_, s) => TestDayScreen(date: s.pathParameters['date']!))],
                ),
                GoRoute(
                  path: 'injuries',
                  builder: (_, _) => const InjuriesScreen(),
                  routes: [GoRoute(path: 'new', builder: (_, _) => const InjuryFormScreen())],
                ),
                GoRoute(
                  path: 'players/:id',
                  builder: (_, s) => PlayerScreen(id: s.pathParameters['id']!),
                  routes: [
                    GoRoute(path: 'edit', builder: (_, s) => PlayerFormScreen(id: s.pathParameters['id'])),
                    GoRoute(path: 'profile', builder: (_, s) => PlayerProfileFormScreen(playerId: s.pathParameters['id']!)),
                    GoRoute(path: 'medical', builder: (_, s) => PlayerMedicalFormScreen(playerId: s.pathParameters['id']!)),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
                GoRoute(path: 'password', builder: (_, _) => const ChangePasswordScreen()),
                GoRoute(
                  path: 'admin',
                  builder: (_, _) => const StaffAccountsScreen(),
                  routes: [
                    GoRoute(path: 'new', builder: (_, _) => const CreateAccountScreen()),
                    GoRoute(path: 'roles', builder: (_, _) => const RolesScreen()),
                    GoRoute(path: 'players', builder: (_, _) => const PlayerAccountsScreen()),
                    GoRoute(path: 'account/:id', builder: (_, s) => AccountScreen(userId: s.pathParameters['id']!)),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

/// Écrans ouverts à un compte joueur : son espace (accueil), son profil, la synchronisation.
final _playerRoutes =
    RegExp(r'^/(home(/results|/dossier/[^/]+|/(wellness|survey)/[^/]+/[^/]+)?|profile(/edit|/password)?|sync)$');

/// Permission nécessaire pour ouvrir un écran (null : écran ouvert à tout le staff).
String? requiredPermission(String location) {
  final rules = <(RegExp, String)>[
    (RegExp(r'^/home/load$'), 'seances.view'),
    (RegExp(r'^/sessions/wellness/new$'), 'bienetre.edit'),
    (RegExp(r'^/sessions/wellness/[^/]+/[^/]+$'), 'bienetre.edit'),
    (RegExp(r'^/sessions/wellness'), 'bienetre.view'),
    (RegExp(r'^/sessions/new$'), 'seances.add'),
    (RegExp(r'^/sessions/[^/]+/edit$'), 'seances.edit'),
    (RegExp(r'^/sessions/[^/]+/(attendance|close)$'), 'seances.appel'),
    (RegExp(r'^/sessions/[^/]+/wellness'), 'bienetre.view'),
    (RegExp(r'^/(sessions|matches)/[^/]+/injury/'), 'blessures.add'),
    (RegExp(r'/tactic/'), 'tactiques.view'),
    (RegExp(r'^/sessions'), 'seances.view'),
    (RegExp(r'^/matches/new$'), 'matchs.add'),
    (RegExp(r'^/matches/[^/]+/edit$'), 'matchs.edit'),
    (RegExp(r'^/matches/[^/]+/(squad|end|lineup)$'), 'matchs.jouer'),
    (RegExp(r'^/matches'), 'matchs.view'),
    (RegExp(r'^/team/new$'), 'equipes.add'),
    (RegExp(r'^/team/edit$'), 'equipes.edit'),
    (RegExp(r'^/team/import$'), 'import.use'),
    (RegExp(r'^/team/tests'), 'tests.view'),
    (RegExp(r'^/team/tactics'), 'tactiques.view'),
    (RegExp(r'^/team/injuries/new$'), 'blessures.add'),
    (RegExp(r'^/team/injuries'), 'blessures.view'),
    (RegExp(r'^/team/players/(new|club)$'), 'effectif.add'),
    (RegExp(r'^/team/players/[^/]+/edit$'), 'effectif.edit'),
    (RegExp(r'^/team/players/[^/]+/profile$'), 'dossier.edit'),
    (RegExp(r'^/team/players/[^/]+/medical$'), 'medical.edit'),
    (RegExp(r'^/team'), 'effectif.view'),
  ];
  return rules.where((r) => r.$1.hasMatch(location)).firstOrNull?.$2;
}

/// Raccourci pour afficher un message court en bas de l'écran (specs §4.2).
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
