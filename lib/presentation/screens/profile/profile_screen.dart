import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Stub MVP — Perfil mínimo com atalho para Config (smoke).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Config remota (debug)'),
            subtitle: const Text('GET /config'),
            onTap: () => context.go('/perfil/config'),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Config (rota direta)'),
            onTap: () => context.push('/debug/config'),
          ),
        ],
      ),
    );
  }
}
