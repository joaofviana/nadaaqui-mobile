import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/checkin/checkin_tab_screen.dart';
import '../screens/config/config_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/places/place_detail_screen.dart';
import '../screens/places/places_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../shell/main_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mapaKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _feedKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _checkinKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _perfilKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/mapa',
    routes: [
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
                builder: (context, state) => const PlacesScreen(),
                routes: [
                  GoRoute(
                    path: 'place/:placeId',
                    builder: (context, state) {
                      final id = state.pathParameters['placeId']!;
                      return PlaceDetailScreen(placeId: id);
                    },
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
            navigatorKey: _checkinKey,
            routes: [
              GoRoute(
                path: '/checkin',
                builder: (context, state) => const CheckinTabScreen(),
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
      // Rota direta de debug para Config (fora das tabs, útil em smoke).
      GoRoute(
        path: '/debug/config',
        builder: (context, state) => const ConfigScreen(),
      ),
    ],
  );
}
