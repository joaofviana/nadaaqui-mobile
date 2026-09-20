import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/api_config.dart';
import 'core/session/session_store.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug: log configuration
  debugPrint('=== NadaAqui Debug Info ===');
  debugPrint('Use Supabase: ${ApiConfig.useSupabase}');
  debugPrint('Supabase URL: ${ApiConfig.supabaseUrl}');
  debugPrint('Supabase Anon Key: ${ApiConfig.supabaseAnonKey.isNotEmpty ? "Present" : "MISSING"}');
  debugPrint('Base URL: ${ApiConfig.baseUrl}');
  debugPrint('Force Mock: ${ApiConfig.forceMock}');
  debugPrint('Missing Live Key: ${ApiConfig.missingLiveKey}');
  debugPrint('==========================');
  
  final container = ProviderContainer();
  final router = createAppRouter(container);
  
  runApp(UncontrolledProviderScope(
    container: container,
    child: NadaAquiApp(router: router),
  ));
}

class NadaAquiApp extends StatelessWidget {
  const NadaAquiApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NadaAqui',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // OLED default (TOKENS)
      theme: buildNadaAquiLightTheme(),
      darkTheme: buildNadaAquiDarkTheme(),
      routerConfig: router,
    );
  }
}
