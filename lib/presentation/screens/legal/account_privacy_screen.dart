import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../theme/app_colors.dart';

/// Conta, documentos legais e exclusão (Play Store).
class AccountPrivacyScreen extends ConsumerStatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  ConsumerState<AccountPrivacyScreen> createState() =>
      _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends ConsumerState<AccountPrivacyScreen> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final t = NadaTokens.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          'Excluir conta?',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Isso apaga permanentemente sua conta, histórico de nados, posts e participação em clubes. Não dá para desfazer.',
          style: TextStyle(color: t.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: t.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Excluir',
              style: TextStyle(color: t.error, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    // Segunda confirmação (exigência de intenção clara)
    final ok2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          'Confirmar exclusão',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Tem certeza? Sua conta será removida agora.',
          style: TextStyle(color: t.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Voltar', style: TextStyle(color: t.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir definitivamente'),
          ),
        ],
      ),
    );
    if (ok2 != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      final session = ref.read(sessionStoreProvider);
      if (session == null) {
        throw Exception('Sem sessão');
      }
      final api = AuthApi(ref.read(dioProvider));
      await api.deleteAccount(accessToken: session.accessToken);
      ref.read(sessionStoreProvider.notifier).clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída.')),
      );
      context.go('/entrar');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Não foi possível excluir agora. Verifique a conexão e tente de novo.',
          ),
          backgroundColor: t.errorBg,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final loggedIn = ref.watch(sessionStoreProvider) != null;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: const Text('Conta e privacidade'),
      ),
      body: ListView(
        children: [
          _SectionLabel('Documentos'),
          ListTile(
            title: Text('Política de Privacidade',
                style: TextStyle(color: t.text)),
            trailing: Icon(Icons.chevron_right, color: t.textMuted),
            onTap: () => context.push('/legal/privacidade'),
          ),
          ListTile(
            title: Text('Termos de Uso', style: TextStyle(color: t.text)),
            trailing: Icon(Icons.chevron_right, color: t.textMuted),
            onTap: () => context.push('/legal/termos'),
          ),
          if (loggedIn) ...[
            _SectionLabel('Conta'),
            ListTile(
              title: Text(
                'Excluir conta',
                style: TextStyle(color: t.error, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Remove permanentemente seus dados do NadaAqui',
                style: TextStyle(color: t.textMuted, fontSize: 13),
              ),
              trailing: _deleting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.delete_outline, color: t.error),
              onTap: _deleting ? null : _confirmDelete,
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Localização é usada só para piscinas próximas e check-in, '
              'quando você autoriza no sistema.',
              style: TextStyle(color: t.textMuted, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: t.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
