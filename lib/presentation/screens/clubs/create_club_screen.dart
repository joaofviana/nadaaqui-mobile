import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/clubs_store.dart';
import '../../theme/app_colors.dart';

/// Formulário sóbrio de criação de clube (campos no estilo Strava).
class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _city = TextEditingController();
  bool _public = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Nome com pelo menos 3 caracteres.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final club = await ref.read(clubsStoreProvider.notifier).createClub(
            name: name,
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
            isPublic: _public,
          );
      if (!mounted) return;
      if (club != null) {
        context.go('/clubes/${club.id}');
      } else {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Não foi possível criar o clube. Tente de novo.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: const Text('Novo clube'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Criar',
              style: TextStyle(
                color: t.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Field(
            label: 'Nome',
            required: true,
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              decoration: _dec(t, 'Ex: Nadadores da Mooca'),
            ),
          ),
          _Field(
            label: 'Cidade',
            child: TextField(
              controller: _city,
              textCapitalization: TextCapitalization.words,
              decoration: _dec(t, 'São Paulo'),
            ),
          ),
          _Field(
            label: 'Descrição',
            child: TextField(
              controller: _desc,
              maxLines: 4,
              maxLength: 500,
              decoration: _dec(
                t,
                'Treinos semanais, ritmo misto, foco em constância.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Clube público',
              style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Qualquer pessoa pode entrar. Privado exige convite (em breve).',
              style: TextStyle(color: t.textMuted, fontSize: 13),
            ),
            value: _public,
            activeColor: t.accent,
            onChanged: (v) => setState(() => _public = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: t.error, fontSize: 14)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: t.accent,
                foregroundColor: const Color(0xFF042F2E),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Criar clube',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(NadaTokens t, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: t.inputPlaceholder),
      filled: true,
      fillColor: t.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.accent),
      ),
      counterStyle: TextStyle(color: t.textMuted, fontSize: 11),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.required = false,
  });
  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            required ? '$label *' : label,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
