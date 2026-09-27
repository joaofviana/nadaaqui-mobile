import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/clubs_store.dart';
import '../../theme/app_colors.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _place = TextEditingController();
  final _capacity = TextEditingController();
  String _type = 'workout';
  DateTime _starts = DateTime.now().add(const Duration(days: 1)).copyWith(
        hour: 7,
        minute: 0,
        second: 0,
        millisecond: 0,
      );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _place.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _starts,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    setState(() {
      _starts = DateTime(d.year, d.month, d.day, _starts.hour, _starts.minute);
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_starts),
    );
    if (t == null) return;
    setState(() {
      _starts = DateTime(
        _starts.year,
        _starts.month,
        _starts.day,
        t.hour,
        t.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.length < 3) {
      setState(() => _error = 'Título com pelo menos 3 caracteres.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final cap = int.tryParse(_capacity.text.trim());
      await ref.read(clubsStoreProvider.notifier).createEvent(
            clubId: widget.clubId,
            title: title,
            startsAt: _starts,
            eventType: _type,
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            placeName: _place.text.trim().isEmpty ? null : _place.text.trim(),
            capacity: cap,
          );
      if (mounted) context.pop();
    } catch (_) {
      setState(() {
        _error = 'Não foi possível criar o evento.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final dateLabel =
        '${_starts.day.toString().padLeft(2, '0')}/${_starts.month.toString().padLeft(2, '0')}/${_starts.year}';
    final timeLabel =
        '${_starts.hour.toString().padLeft(2, '0')}:${_starts.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        title: const Text('Novo evento'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Publicar',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _L(
            'Título *',
            TextField(
              controller: _title,
              maxLength: 125,
              decoration: _dec(t, 'Ex: Treino aberto — Crawl 7h'),
            ),
          ),
          _L(
            'Tipo',
            Wrap(
              spacing: 8,
              children: [
                _Chip(
                  label: 'Treino',
                  selected: _type == 'workout',
                  onTap: () => setState(() => _type = 'workout'),
                ),
                _Chip(
                  label: 'Social',
                  selected: _type == 'social',
                  onTap: () => setState(() => _type = 'social'),
                ),
                _Chip(
                  label: 'Competição',
                  selected: _type == 'competition',
                  onTap: () => setState(() => _type = 'competition'),
                ),
              ],
            ),
          ),
          _L(
            'Data e hora *',
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(dateLabel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(timeLabel),
                  ),
                ),
              ],
            ),
          ),
          _L(
            'Local',
            TextField(
              controller: _place,
              decoration: _dec(t, 'Sesc 24 de Maio — piscina 25m'),
            ),
          ),
          _L(
            'Limite de vagas (opcional)',
            TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: _dec(t, 'Ex: 12'),
            ),
          ),
          _L(
            'Descrição',
            TextField(
              controller: _desc,
              maxLines: 3,
              maxLength: 1000,
              decoration: _dec(t, 'Ritmo, o que levar, ponto de encontro…'),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: t.error)),
            ),
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
                      'Publicar evento',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(NadaTokens t, String hint) => InputDecoration(
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
      );
}

class _L extends StatelessWidget {
  const _L(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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

class _Chip extends StatelessWidget {
  const _Chip({
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: t.accent,
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF042F2E) : t.text,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      backgroundColor: t.surface2,
    );
  }
}
