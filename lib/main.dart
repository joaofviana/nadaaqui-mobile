import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/api_config.dart';
import 'core/prefs/app_prefs.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('NadaAqui · supabase=${ApiConfig.useSupabase}');
  }

  runApp(const ProviderScope(child: NadaAquiApp()));
}

class NadaAquiApp extends ConsumerWidget {
  const NadaAquiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(appPrefsProvider);

    return MaterialApp.router(
      title: 'NadaAqui',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,
      theme: buildNadaAquiLightTheme(),
      darkTheme: buildNadaAquiDarkTheme(),
      routerConfig: router,
    );
  }
}
