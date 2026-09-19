import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/api_config.dart';
import '../theme/app_colors.dart';

/// Sem anon key o app NÃO cai no WireMock. Mostra como ligar o live.
class LiveBackendBanner extends StatelessWidget {
  const LiveBackendBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ApiConfig.missingLiveKey) return const SizedBox.shrink();
    final t = NadaTokens.of(context);
    return Material(
      color: t.errorBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backend live desligado',
              style: TextStyle(
                color: t.error,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'O app não usa mais WireMock por padrão. Cole a anon public em dart_defines.json e rode:\n'
              'flutter run --dart-define-from-file=dart_defines.json',
              style: TextStyle(color: t.text, fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 8),
            Text(
              ApiConfig.dashboardUrl,
              style: TextStyle(color: t.accent, fontSize: 11),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: ApiConfig.dashboardUrl),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link do dashboard copiado')),
                    );
                  }
                },
                child: const Text('Copiar dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
