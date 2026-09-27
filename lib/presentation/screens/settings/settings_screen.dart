import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../core/session/session_store.dart';
import '../../../data/api/auth_api.dart';
import '../../../data/models/user.dart';
import '../../theme/app_colors.dart';

/// Configurações de produção: conta, privacidade, preferências, sobre.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '…';
  bool _deleting = false;
  bool _savingName = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    }).catchError((_) {
      if (mounted) setState(() => _version = '0.1.7');
    });
  }

  Future<void> _editName() async {
    final session = ref.read(sessionStoreProvider);
    final user = session?.user;
    if (user == null) return;
    final t = NadaTokens.of(context);
    final ctrl = TextEditingController(text: user.displayName);

    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Nome', style: TextStyle(color: t.text)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: t.text),
          decoration: InputDecoration(
            hintText: 'Seu nome',
            hintStyle: TextStyle(color: t.inputPlaceholder),
            filled: true,
            fillColor: t.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: t.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('Salvar',
                style: TextStyle(color: t.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (next == null || next.length < 2 || next == user.displayName) return;

    setState(() => _savingName = true);
    try {
      final updated = User(
        id: user.id,
        email: user.email,
        displayName: next,
        avatarUrl: user.avatarUrl,
        showInPresence: user.showInPresence,
      );
      ref.read(sessionStoreProvider.notifier).updateUser(updated);
      // Best-effort no backend (perfil)
      try {
        final dio = ref.read(dioProvider);
        await dio.patch(
          '/profiles?id=eq.${user.id}',
          data: {'display_name': next},
        );
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nome atualizado')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _changePassword() async {
    final t = NadaTokens.of(context);
    final pass = TextEditingController();
    final confirm = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Nova senha', style: TextStyle(color: t.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pass,
              obscureText: true,
              style: TextStyle(color: t.text),
              decoration: InputDecoration(
                labelText: 'Nova senha',
                labelStyle: TextStyle(color: t.textMuted),
                filled: true,
                fillColor: t.bg,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirm,
              obscureText: true,
              style: TextStyle(color: t.text),
              decoration: InputDecoration(
                labelText: 'Confirmar',
                labelStyle: TextStyle(color: t.textMuted),
                filled: true,
                fillColor: t.bg,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: t.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Salvar',
                style: TextStyle(color: t.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    final p1 = pass.text;
    final p2 = confirm.text;
    pass.dispose();
    confirm.dispose();
    if (ok != true) return;
    if (p1.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha mínima: 6 caracteres')),
      );
      return;
    }
    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senhas não conferem')),
      );
      return;
    }

    try {
      final session = ref.read(sessionStoreProvider);
      if (session == null) return;
      final dio = ref.read(dioProvider);
      // Supabase GoTrue user update
      final root = session.accessToken;
      await dio.put(
        '${_authRoot()}/user',
        data: {'password': p1},
        options: Options(
          headers: {
            'apikey': _anonKey(),
            'Authorization': 'Bearer $root',
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível alterar a senha agora.'),
          ),
        );
      }
    }
  }

  String _authRoot() {
    // Import via ApiConfig would be cleaner — inline from dio base is enough
    return 'https://hanqanaaimzthlqtrmks.supabase.co/auth/v1';
  }

  String _anonKey() {
    // Prefer reading from existing session traffic; key is in CI define
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
  }

  Future<void> _deleteAccount() async {
    final t = NadaTokens.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Excluir conta?',
            style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
        content: Text(
          'Apaga permanentemente conta, nados, posts e clubes. Não dá para desfazer.',
          style: TextStyle(color: t.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: t.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir',
                style: TextStyle(color: t.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final ok2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Confirmar exclusão',
            style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
        content: Text('Tem certeza? A conta será removida agora.',
            style: TextStyle(color: t.textMuted)),
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
      if (session == null) throw Exception('no session');
      await AuthApi(ref.read(dioProvider))
          .deleteAccount(accessToken: session.accessToken);
      ref.read(sessionStoreProvider.notifier).clear();
      if (!mounted) return;
      context.go('/entrar');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível excluir. Aplique a migration delete_my_account no Supabase.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _logout() async {
    try {
      final session = ref.read(sessionStoreProvider);
      if (session != null) {
        await AuthApi(ref.read(dioProvider))
            .logout(accessToken: session.accessToken);
      }
    } catch (_) {}
    ref.read(sessionStoreProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final session = ref.watch(sessionStoreProvider);
    final user = session?.user;
    final prefs = ref.watch(appPrefsProvider);
    final prefsN = ref.read(appPrefsProvider.notifier);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // ── Conta ───────────────────────────────────────────
          _Section('Conta'),
          if (user != null) ...[
            ListTile(
              title: Text('Nome', style: TextStyle(color: t.text)),
              subtitle: Text(
                _savingName ? 'Salvando…' : user.displayName,
                style: TextStyle(color: t.textMuted),
              ),
              trailing: Icon(Icons.chevron_right, color: t.textMuted),
              onTap: _savingName ? null : _editName,
            ),
            ListTile(
              title: Text('E-mail', style: TextStyle(color: t.text)),
              subtitle: Text(user.email, style: TextStyle(color: t.textMuted)),
            ),
            ListTile(
              title: Text('Alterar senha', style: TextStyle(color: t.text)),
              trailing: Icon(Icons.chevron_right, color: t.textMuted),
              onTap: _changePassword,
            ),
            ListTile(
              title: Text(
                'Excluir conta',
                style: TextStyle(color: t.error, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Remove seus dados do NadaAqui',
                style: TextStyle(color: t.textMuted, fontSize: 13),
              ),
              trailing: _deleting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.delete_outline, color: t.error),
              onTap: _deleting ? null : _deleteAccount,
            ),
            ListTile(
              title: Text('Sair', style: TextStyle(color: t.error)),
              leading: Icon(Icons.logout, color: t.error),
              onTap: _logout,
            ),
          ] else
            ListTile(
              title: Text('Entrar', style: TextStyle(color: t.accent)),
              onTap: () => context.push('/entrar'),
            ),

          // ── Privacidade ─────────────────────────────────────
          _Section('Privacidade'),
          SwitchListTile(
            title: Text('Mostrar na presença do local',
                style: TextStyle(color: t.text)),
            subtitle: Text(
              'Outros nadadores veem que você está na piscina',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
            value: prefs.showInPresence,
            activeColor: t.accent,
            onChanged: (v) {
              prefsN.setShowInPresence(v);
              final u = user;
              if (u != null) {
                ref.read(sessionStoreProvider.notifier).updateUser(
                      User(
                        id: u.id,
                        email: u.email,
                        displayName: u.displayName,
                        avatarUrl: u.avatarUrl,
                        showInPresence: v,
                      ),
                    );
              }
            },
          ),
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

          // ── Localização ─────────────────────────────────────
          _Section('Localização'),
          ListTile(
            title: Text('Permissões do sistema',
                style: TextStyle(color: t.text)),
            subtitle: Text(
              'Usada só para piscinas próximas e check-in',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
            trailing: Icon(Icons.open_in_new, color: t.textMuted, size: 20),
            onTap: () => AppSettings.openAppSettings(
              type: AppSettingsType.location,
            ),
          ),

          // ── Notificações ────────────────────────────────────
          _Section('Notificações'),
          SwitchListTile(
            title: Text('Notificações', style: TextStyle(color: t.text)),
            subtitle: Text(
              'Preferência salva. Push chega em breve.',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
            value: prefs.notificationsEnabled,
            activeColor: t.accent,
            onChanged: prefsN.setNotificationsEnabled,
          ),

          // ── Preferências ────────────────────────────────────
          _Section('Preferências'),
          ListTile(
            title: Text('Tema', style: TextStyle(color: t.text)),
            subtitle: Text(
              _themeLabel(prefs.themeMode),
              style: TextStyle(color: t.textMuted),
            ),
            trailing: Icon(Icons.chevron_right, color: t.textMuted),
            onTap: () => _pickTheme(prefs.themeMode),
          ),
          SwitchListTile(
            title: Text('Distância em km', style: TextStyle(color: t.text)),
            subtitle: Text(
              prefs.distanceInKm
                  ? 'Exibir km quando fizer sentido'
                  : 'Exibir metros (padrão natação)',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
            value: prefs.distanceInKm,
            activeColor: t.accent,
            onChanged: prefsN.setDistanceInKm,
          ),

          // ── Sobre ───────────────────────────────────────────
          _Section('Sobre'),
          ListTile(
            title: Text('Versão', style: TextStyle(color: t.text)),
            subtitle: Text(_version, style: TextStyle(color: t.textMuted)),
          ),
          ListTile(
            title: Text('Suporte', style: TextStyle(color: t.text)),
            subtitle: Text(
              'Use o e-mail da ficha do app na loja',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.light => 'Claro',
        ThemeMode.system => 'Sistema',
        ThemeMode.dark => 'Escuro',
      };

  Future<void> _pickTheme(ThemeMode current) async {
    final t = NadaTokens.of(context);
    final chosen = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Escuro', style: TextStyle(color: t.text)),
              trailing: current == ThemeMode.dark
                  ? Icon(Icons.check, color: t.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, ThemeMode.dark),
            ),
            ListTile(
              title: Text('Claro', style: TextStyle(color: t.text)),
              trailing: current == ThemeMode.light
                  ? Icon(Icons.check, color: t.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, ThemeMode.light),
            ),
            ListTile(
              title: Text('Sistema', style: TextStyle(color: t.text)),
              trailing: current == ThemeMode.system
                  ? Icon(Icons.check, color: t.accent)
                  : null,
              onTap: () => Navigator.pop(ctx, ThemeMode.system),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) {
      ref.read(appPrefsProvider.notifier).setThemeMode(chosen);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
      child: Text(
        label.toUpperCase(),
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
