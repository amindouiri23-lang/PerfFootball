import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_screens.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_screens.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screens.dart';
import 'widgets/app_shell.dart';
import 'widgets/coming_soon.dart';

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
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/new-password', builder: (_, _) => const NewPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/sessions', builder: (_, _) => const ComingSoon(title: 'Séances')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/matches', builder: (_, _) => const ComingSoon(title: 'Matchs')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/team', builder: (_, _) => const ComingSoon(title: 'Mon équipe')),
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
                  routes: [GoRoute(path: 'new', builder: (_, _) => const CreateAccountScreen())],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

/// Raccourci pour afficher un message court en bas de l'écran (specs §4.2).
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
