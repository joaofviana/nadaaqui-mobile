import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/brand_wordmark.dart';

/// E-mail + senha + criar conta (Supabase Auth / WireMock login).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _signup = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Confira o e-mail e tente de novo.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = ref.read(sessionStoreProvider.notifier);
      if (_signup) {
        await store.signUp(
          email: email,
          password: password,
          displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
        );
      } else {
        await store.signIn(email: email, password: password);
      }
      if (mounted) context.pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
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
        backgroundColor: t.bg,
        foregroundColor: t.text,
        elevation: 0,
        title: Text(_signup ? 'Criar conta' : 'Entrar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const BrandWordmark(height: 32),
            const SizedBox(height: 12),
            Text(
              _signup
                  ? 'Crie uma conta para fazer check-in.'
                  : 'Check-in pede conta. Mapa e ficha continuam livres.',
              style: TextStyle(color: t.textMuted, height: 1.4),
            ),
            const SizedBox(height: 28),
            if (_signup) ...[
              TextField(
                controller: _name,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: t.text),
                decoration: InputDecoration(
                  labelText: 'Nome (opcional)',
                  labelStyle: TextStyle(color: t.textMuted),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: t.text),
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: t.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _busy ? null : _submit(),
              style: TextStyle(color: t.text),
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: t.textMuted),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: t.textMuted,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: t.error, height: 1.35),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_signup ? 'Criar conta' : 'Entrar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _signup = !_signup;
                        _error = null;
                      }),
              child: Text(
                _signup
                    ? 'Já tenho conta'
                    : 'Criar conta',
                style: TextStyle(color: t.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
