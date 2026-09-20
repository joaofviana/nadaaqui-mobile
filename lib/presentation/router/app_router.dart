import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/challenges/challenges_screen.dart';
import '../screens/compose/compose_screen.dart';
import '../screens/config/config_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/leaderboard/place_leaderboard_screen.dart';
import '../screens/places/place_detail_screen.dart';
import '../screens/places/places_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/workout/workout_builder_screen.dart';
import '../shell/main_shell.dart';
import '../../core/session/session_store.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mapaKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _feedKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _treinoKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _perfilKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(ProviderContainer container) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/mapa',
    redirect: (context, state) {
      final session = container.read(sessionStoreProvider);
      final isAuthenticated = session?.accessToken.isNotEmpty == true;
      final isAuthRoute = state.matchedLocation == '/entrar';
      
      // Se não está autenticado e não está na tela de login, vai para login
      if (!isAuthenticated && !isAuthRoute) {
        return '/entrar';
      }
      
      // Se está autenticado e está na tela de login, vai para o app
      if (isAuthenticated && isAuthRoute) {
        return '/mapa';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/entrar',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final modo = state.uri.queryParameters['modo'];
          return LoginScreen(initialSignUp: modo == 'criar');
        },
      ),
      GoRoute(
        path: '/compose',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return ComposeScreen(
            kind: composeKindFromQuery(q['tipo']),
            placeId: q['placeId'],
            placeName: q['placeName'],
          );
        },
      ),
      GoRoute(
        path: '/desafios',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ChallengesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _mapaKey,
            routes: [
              GoRoute(
                path: '/mapa',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'explorar',
                    builder: (context, state) => const PlacesScreen(),
                  ),
                  GoRoute(
                    path: 'place/:placeId',
                    builder: (context, state) {
                      final id = state.pathParameters['placeId']!;
                      return PlaceDetailScreen(placeId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'leaderboard',
                        builder: (context, state) {
                          final id = state.pathParameters['placeId']!;
                          final name = state.uri.queryParameters['name'] ?? 'Local';
                          return PlaceLeaderboardScreen(
                            placeId: id,
                            placeName: name,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _feedKey,
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _treinoKey,
            routes: [
              GoRoute(
                path: '/treino',
                builder: (context, state) => const WorkoutBuilderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _perfilKey,
            routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'config',
                    builder: (context, state) => const ConfigScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/debug/config',
        builder: (context, state) => const ConfigScreen(),
      ),
    ],
  );
}
