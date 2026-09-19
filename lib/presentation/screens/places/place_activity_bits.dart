import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/swim_log_store.dart';
import '../../theme/app_colors.dart';

/// Heatmap de horário + ranking do tanque (local / seed).
class PlaceActivityBits extends ConsumerWidget {
  const PlaceActivityBits({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  final String placeId;
  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(swimLogStoreProvider);
    final hours = hourlyHeatFor(placeId);
    final board = boardForPlace(placeId, mine);
    final t = NadaTokens.of(context);
    final maxH = hours.reduce((a, b) => a > b ? a : b).clamp(1, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Quando a água esquenta',
          style: TextStyle(
            color: t.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Movimento típico · 6h–21h',
          style: TextStyle(color: t.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < hours.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: 8 + (hours[i] / maxH) * 48,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(
                          alpha: 0.2 + (hours[i] / 10) * 0.8,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('6h', style: TextStyle(color: t.textMuted, fontSize: 11)),
            Text('12h', style: TextStyle(color: t.textMuted, fontSize: 11)),
            Text('18h', style: TextStyle(color: t.textMuted, fontSize: 11)),
            Text('21h', style: TextStyle(color: t.textMuted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Ranking do tanque',
          style: TextStyle(
            color: t.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Minutos este mês em $placeName',
          style: TextStyle(color: t.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < board.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: t.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: board[i].you
                      ? const Color(0xFF99F6E4)
                      : t.surface2,
                  child: Text(
                    board[i].letter,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    board[i].name,
                    style: TextStyle(
                      color: t.text,
                      fontWeight:
                          board[i].you ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${board[i].minutes} min',
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
