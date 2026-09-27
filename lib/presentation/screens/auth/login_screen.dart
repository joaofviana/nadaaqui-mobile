import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../theme/app_colors.dart';

enum _AuthMode { signIn, signUp, recover }

/// Login / cadastro / recuperar senha — dark, teal, fluxo claro.
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
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  late _AuthMode _mode;
  bool _busy = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialSignUp ? _AuthMode.signUp : _AuthMode.signIn;
    for (final c in [_email, _password, _confirm, _name]) {
      c.addListener(_onChanged);
    }
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
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final email = _email.text.trim();
    final pass = _password.text;
    if (!email.contains('@') || email.length < 5) return false;
    switch (_mode) {
      case _AuthMode.recover:
        return true;
      case _AuthMode.signIn:
        return pass.isNotEmpty;
      case _AuthMode.signUp:
        return _name.text.trim().length >= 2 &&
            pass.length >= 6 &&
            pass == _confirm.text;
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    final api = AuthApi(ref.read(dioProvider));
    try {
      if (_mode == _AuthMode.recover) {
        await api.recoverPassword(email: _email.text.trim());
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
              email: _email.text.trim(),
              password: _password.text,
              displayName: _name.text.trim(),
            )
          : await api.signIn(
              email: _email.text.trim(),
              password: _password.text,
            );
      ref.read(sessionStoreProvider.notifier).setSession(session);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/mapa');
      }
    } catch (e) {
      final err = e is ApiError ? e : extractApiError(e);
      setState(() => _error = err.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _setMode(_AuthMode next) {
    if (_mode == next) return;
    setState(() {
      _mode = next;
      _error = null;
      _info = null;
      _obscurePass = true;
      _obscureConfirm = true;
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    final title = switch (_mode) {
      _AuthMode.signIn => 'Bem-vindo de volta',
      _AuthMode.signUp => 'Crie sua conta',
      _AuthMode.recover => 'Recuperar senha',
    };
    final subtitle = switch (_mode) {
      _AuthMode.signIn => 'Entre para registrar treinos e achar piscinas perto.',
      _AuthMode.signUp =>
        'Check-in, feed e clubes de natação em um só lugar.',
      _AuthMode.recover =>
        'Informe o e-mail da conta. Enviamos um link se ele existir.',
    };
    final ctaLabel = switch (_mode) {
      _AuthMode.signIn => 'Entrar',
      _AuthMode.signUp => 'Criar conta',
      _AuthMode.recover => 'Enviar link',
    };

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // Fundo suave no topo (marca, sem poluição)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    t.accent.withValues(alpha: 0.12),
                    t.bg,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _goBack,
                        icon: Icon(Icons.arrow_back_ios_new, color: t.text, size: 20),
                        tooltip: 'Voltar',
                      ),
                      const Spacer(),
                      if (_mode == _AuthMode.recover)
                        TextButton(
                          onPressed: () => _setMode(_AuthMode.signIn),
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              color: t.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Image.asset(
                          'assets/brand/app-icon-tight.png',
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: t.accent.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: t.accent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Icon(Icons.waves_rounded,
                                color: t.accent, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'NadaAqui',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_mode != _AuthMode.recover) ...[
                        _Segment(
                          signIn: _mode == _AuthMode.signIn,
                          onSignIn: () => _setMode(_AuthMode.signIn),
                          onSignUp: () => _setMode(_AuthMode.signUp),
                        ),
                        const SizedBox(height: 28),
                      ],
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.text,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: t.textMuted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_mode == _AuthMode.signUp) ...[
                              _LabeledField(
                                label: 'Nome',
                                child: TextField(
                                  controller: _name,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  style: TextStyle(color: t.text, fontSize: 16),
                                  decoration: _fieldDeco(t, 'Como você se chama'),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            _LabeledField(
                              label: 'E-mail',
                              child: TextField(
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                style: TextStyle(color: t.text, fontSize: 16),
                                decoration: _fieldDeco(t, 'seu@email.com'),
                                onSubmitted: (_) => _passFocus.requestFocus(),
                              ),
                            ),
                            if (_mode != _AuthMode.recover) ...[
                              const SizedBox(height: 14),
                              _LabeledField(
                                label: 'Senha',
                                child: TextField(
                                  controller: _password,
                                  focusNode: _passFocus,
                                  obscureText: _obscurePass,
                                  autofillHints: _mode == _AuthMode.signUp
                                      ? const [AutofillHints.newPassword]
                                      : const [AutofillHints.password],
                                  textInputAction: _mode == _AuthMode.signUp
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  onSubmitted: (_) {
                                    if (_mode == _AuthMode.signIn) _submit();
                                  },
                                  style:
                                      TextStyle(color: t.text, fontSize: 16),
                                  decoration: _fieldDeco(
                                    t,
                                    _mode == _AuthMode.signUp
                                        ? 'Mínimo 6 caracteres'
                                        : 'Sua senha',
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () => _obscurePass = !_obscurePass,
                                      ),
                                      icon: Icon(
                                        _obscurePass
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: t.textMuted,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_mode == _AuthMode.signUp) ...[
                              const SizedBox(height: 14),
                              _LabeledField(
                                label: 'Confirmar senha',
                                child: TextField(
                                  controller: _confirm,
                                  obscureText: _obscureConfirm,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(),
                                  style:
                                      TextStyle(color: t.text, fontSize: 16),
                                  decoration: _fieldDeco(
                                    t,
                                    'Repita a senha',
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: t.textMuted,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_password.text.isNotEmpty &&
                                  _password.text.length < 6) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'A senha precisa ter pelo menos 6 caracteres.',
                                  style: TextStyle(
                                    color: t.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              if (_confirm.text.isNotEmpty &&
                                  _password.text != _confirm.text) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'As senhas não conferem.',
                                  style: TextStyle(
                                    color: t.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      if (_mode == _AuthMode.signIn) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _setMode(_AuthMode.recover),
                            style: TextButton.styleFrom(
                              foregroundColor: t.textMuted,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _Banner(
                          text: _error!,
                          bg: t.errorBg,
                          fg: t.error,
                        ),
                      ],
                      if (_info != null) ...[
                        const SizedBox(height: 12),
                        _Banner(
                          text: _info!,
                          bg: t.accent.withValues(alpha: 0.12),
                          fg: t.accent,
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: (!_canSubmit || _busy) ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: t.accent,
                            disabledBackgroundColor:
                                t.accent.withValues(alpha: 0.35),
                            foregroundColor: const Color(0xFF042F2E),
                            disabledForegroundColor:
                                const Color(0xFF042F2E).withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFF042F2E),
                                  ),
                                )
                              : Text(ctaLabel),
                        ),
                      ),
                      if (_mode == _AuthMode.recover) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => _setMode(_AuthMode.signIn),
                            child: Text(
                              'Voltar ao login',
                              style: TextStyle(
                                color: t.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(
    NadaTokens t,
    String hint, {
    Widget? suffix,
  }) {
    final radius = BorderRadius.circular(14);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: t.inputPlaceholder, fontSize: 15),
      filled: true,
      fillColor: t.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: t.accent, width: 1.5),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.signIn,
    required this.onSignIn,
    required this.onSignUp,
  });

  final bool signIn;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              label: 'Entrar',
              selected: signIn,
              onTap: onSignIn,
            ),
          ),
          Expanded(
            child: _SegBtn(
              label: 'Criar conta',
              selected: !signIn,
              onTap: onSignUp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Material(
      color: selected ? t.surface2 : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? t.text : t.textMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.bg,
    required this.fg,
  });

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: fg, fontSize: 14, height: 1.35),
      ),
    );
  }
}
