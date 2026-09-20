import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../data/models/swim_challenge.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';

// Mock data para demonstração
final mockChallenges = [
  SwimChallenge(
    id: '1',
    title: 'Desafio 100km',
    description: 'Nade 100km este mês e ganhe o badge de ouro!',
    targetType: ChallengeTargetType.meters,
    targetValue: 100000,
    participants: 234,
    endDate: DateTime.now().add(const Duration(days: 15)),
    isActive: true,
    isJoined: true,
  ),
  SwimChallenge(
    id: '2',
    title: 'Maratona de Sessões',
    description: 'Complete 20 sessões de natação em 30 dias',
    targetType: ChallengeTargetType.sessions,
    targetValue: 20,
    participants: 156,
    endDate: DateTime.now().add(const Duration(days: 10)),
    isActive: true,
    isJoined: false,
  ),
  SwimChallenge(
    id: '3',
    title: 'Nado Matinal',
    description: 'Acumule 500 minutos de nado antes das 10h',
    targetType: ChallengeTargetType.minutes,
    targetValue: 500,
    participants: 89,
    endDate: DateTime.now().add(const Duration(days: 7)),
    isActive: true,
    isJoined: false,
  ),
];

/// Tela de desafios - estilo GymRats challenges
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = NadaTokens.of(context);
    final challenges = ApiConfig.useSupabase ? mockChallenges : mockChallenges;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Expanded(child: BrandWordmark(height: 28)),
                    IconButton(
                      icon: Icon(Icons.add, color: t.accent),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Criar desafio em breve')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Desafios Ativos',
                  style: TextStyle(
                    color: t.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (challenges.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nenhum desafio ativo no momento.\nFique atento para novos desafios!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.textMuted),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final challenge = challenges[index];
                    return _ChallengeCard(challenge: challenge);
                  },
                  childCount: challenges.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final SwimChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            t.surface.withValues(alpha: 0.8),
            t.surface.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: challenge.isJoined ? t.accent : t.border,
          width: challenge.isJoined ? 2 : 1,
        ),
        boxShadow: challenge.isJoined
            ? [
                BoxShadow(
                  color: t.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            challenge.title,
                            style: TextStyle(
                              color: t.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          if (challenge.isJoined)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: t.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'PARTICIPANDO',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: t.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$daysLeft',
                        style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'dias restantes',
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.flag_outlined, color: t.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Meta: ${challenge.targetLabel}',
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_outline, color: t.textMuted, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${challenge.participants} participantes',
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (challenge.isJoined)
              _ProgressIndicator(challenge: challenge)
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Participar do desafio em breve')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Participar do Desafio'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.challenge});

  final SwimChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    // Mock progress para demonstração
    final mockProgress = 0.35; // 35% completado
    final mockCurrent = (challenge.targetValue * mockProgress).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Seu progresso',
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '$mockCurrent / ${challenge.targetValue} ${challenge.progressLabel}',
              style: TextStyle(
                color: t.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: mockProgress,
            backgroundColor: t.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(t.accent),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(mockProgress * 100).toInt()}% completado',
          style: TextStyle(
            color: t.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}