import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NadaAquiApp()));
}

class NadaAquiApp extends StatefulWidget {
  const NadaAquiApp({super.key});

  @override
  State<NadaAquiApp> createState() => _NadaAquiAppState();
}

class _NadaAquiAppState extends State<NadaAquiApp> {
  late final _router = createAppRouter();

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
