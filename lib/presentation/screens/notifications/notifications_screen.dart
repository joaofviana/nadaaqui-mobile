import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';

/// Aba Notificações — vazia até chegar item de verdade.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandWordmark(height: 28),
              const SizedBox(height: 28),
              Text(
                'Notificações',
                style: TextStyle(
                  color: t.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border),
                ),
                child: Text(
                  'Nenhuma notificação por enquanto.',
                  style: TextStyle(color: t.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
