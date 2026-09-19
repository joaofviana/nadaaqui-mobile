import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../theme/app_colors.dart';

/// Sem anon key o app NÃO cai no WireMock. Copy humana, sem comando de build.
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
              'Não foi possível falar com o NadaAqui',
              style: TextStyle(
                color: t.error,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Não conseguimos alcançar o servidor agora. Tente de novo mais tarde.',
              style: TextStyle(color: t.text, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
