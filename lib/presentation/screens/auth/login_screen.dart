import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!ApiConfig.useSupabase) {
      setState(() => _error = 'Build sem SUPABASE_URL — use o mock só em dev.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = AuthApi(ref.read(dioProvider));
    try {
      final session = _signUp
          ? await api.signUp(
              email: _email.text,
              password: _password.text,
              displayName: _name.text,
            )
          : await api.signIn(
              email: _email.text,
              password: _password.text,
            );
      ref.read(sessionStoreProvider.notifier).setSession(session);
      if (mounted) context.pop(true);
    } catch (e) {
      final err = e is ApiError ? e : extractApiError(e);
      setState(() => _error = err.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(_signUp ? 'Criar conta' : 'Entrar'),
        backgroundColor: t.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Check-in pede conta. Mapa e ficha continuam livres.',
            style: TextStyle(color: t.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          if (_signUp) ...[
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Senha'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFBA1A1A))),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_signUp ? 'Criar conta' : 'Entrar'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _signUp = !_signUp;
                      _error = null;
                    }),
            child: Text(
              _signUp ? 'Já tenho conta' : 'Criar conta',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
