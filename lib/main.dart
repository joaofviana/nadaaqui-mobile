import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/session/session_store.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NadaAquiApp()));
}

class NadaAquiApp extends ConsumerStatefulWidget {
  const NadaAquiApp({super.key});

  @override
  ConsumerState<NadaAquiApp> createState() => _NadaAquiAppState();
}

class _NadaAquiAppState extends ConsumerState<NadaAquiApp> {
  late final _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionStoreProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NadaAqui',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // OLED default (TOKENS)
      theme: buildNadaAquiLightTheme(),
      darkTheme: buildNadaAquiDarkTheme(),
      routerConfig: _router,
    );
  }
}
