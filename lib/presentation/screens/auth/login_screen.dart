import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../theme/app_colors.dart';

enum _AuthMode { signIn, signUp, recover }

/// Telas pool-theme: Entrar, Criar conta, Esqueceu a senha.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialSignUp = false});

  final bool initialSignUp;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _name = TextEditingController();
  late _AuthMode _mode;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialSignUp ? _AuthMode.signUp : _AuthMode.signIn;
    _email.addListener(_onChanged);
    _password.addListener(_onChanged);
    _confirm.addListener(_onChanged);
    _name.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _name.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final email = _email.text.trim();
    final pass = _password.text;
    if (!email.contains('@')) return false;
    switch (_mode) {
      case _AuthMode.recover:
        return email.isNotEmpty;
      case _AuthMode.signIn:
        return pass.isNotEmpty;
      case _AuthMode.signUp:
        return _name.text.trim().isNotEmpty &&
            pass.length >= 6 &&
            pass == _confirm.text;
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final api = AuthApi(ref.read(dioProvider));
    try {
      if (_mode == _AuthMode.recover) {
        await api.recoverPassword(email: _email.text);
        if (!mounted) return;
        setState(() {
          _info =
              'Se esse e-mail existir, enviamos um link para redefinir a senha.';
        });
        return;
      }
      if (_mode == _AuthMode.signUp && _password.text != _confirm.text) {
        setState(() => _error = 'As senhas não conferem.');
        return;
      }
      final session = _mode == _AuthMode.signUp
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

  void _setMode(_AuthMode next) {
    setState(() {
      _mode = next;
      _error = null;
      _info = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final title = switch (_mode) {
      _AuthMode.signIn => 'Entrar',
      _AuthMode.signUp => 'Criar conta',
      _AuthMode.recover => 'Esqueceu a senha?',
    };
    final subtitle = switch (_mode) {
      _AuthMode.signIn => 'Entre com seu e-mail e senha para continuar.',
      _AuthMode.signUp =>
        'Cadastre-se para fazer check-in e seguir lugares para nadar.',
      _AuthMode.recover =>
        'Informe o e-mail da conta. Enviamos um link se ele existir.',
    };
    final ctaLabel = switch (_mode) {
      _AuthMode.signIn => 'Entrar',
      _AuthMode.signUp => 'Criar conta',
      _AuthMode.recover => 'Enviar link',
    };

    final fieldRadius = BorderRadius.circular(16);
    final fieldDeco = InputDecoration(
      filled: true,
      fillColor: t.surface,
      hintStyle: TextStyle(color: t.inputPlaceholder, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: t.accent, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/brand/app-icon-tight.png',
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: t.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.waves, color: t.bg, size: 28),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'NadaAqui',
                  style: TextStyle(
                    color: t.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_mode == _AuthMode.signUp) ...[
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: fieldDeco.copyWith(hintText: 'Nome'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: fieldDeco.copyWith(hintText: 'E-mail'),
            ),
            if (_mode != _AuthMode.recover) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                autofillHints: _mode == _AuthMode.signUp
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
                textInputAction: _mode == _AuthMode.signUp
                    ? TextInputAction.next
                    : TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: fieldDeco.copyWith(hintText: 'Senha'),
              ),
            ],
            if (_mode == _AuthMode.signUp) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirm,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: fieldDeco.copyWith(hintText: 'Confirmar senha'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.error, fontSize: 14),
              ),
            ],
            if (_info != null) ...[
              const SizedBox(height: 14),
              Text(
                _info!,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.accent, fontSize: 14, height: 1.35),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: (!_canSubmit || _busy) ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _canSubmit ? t.ctaStrongBg : t.ctaBg,
                  disabledBackgroundColor: t.ctaBg,
                  foregroundColor: t.ctaStrongFg,
                  disabledForegroundColor: t.ctaStrongFg.withValues(alpha: 0.7),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _busy
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: t.ctaStrongFg,
                        ),
                      )
                    : Text(ctaLabel),
              ),
            ),
            const SizedBox(height: 18),
            if (_mode == _AuthMode.signIn) ...[
              _TextLink(
                label: 'Criar conta',
                color: t.textMuted,
                onTap: () => _setMode(_AuthMode.signUp),
              ),
              _TextLink(
                label: 'Esqueceu a senha?',
                color: t.textMuted,
                onTap: () => _setMode(_AuthMode.recover),
              ),
            ],
            if (_mode == _AuthMode.signUp)
              _TextLink(
                label: 'Já tenho conta',
                color: t.textMuted,
                onTap: () => _setMode(_AuthMode.signIn),
              ),
            if (_mode == _AuthMode.recover)
              _TextLink(
                label: 'Voltar ao login',
                color: t.textMuted,
                onTap: () => _setMode(_AuthMode.signIn),
              ),
            _TextLink(
              label: 'Voltar',
              color: t.textMuted,
              onTap: () => context.pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 6),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
