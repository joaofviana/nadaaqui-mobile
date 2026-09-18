import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Bottom nav 5: Mapa | Feed | Check-in | Notificações | Perfil (HOME-IA).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Contagem real chega em P2. Até lá a tab existe, sem número inventado.
  static const String? notificationBadgeLabel = null;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final idx = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: t.navBg,
          border: Border(top: BorderSide(color: t.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map,
                  label: 'Mapa',
                  selected: idx == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Icons.view_list_outlined,
                  selectedIcon: Icons.view_list,
                  label: 'Feed',
                  selected: idx == 1,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Icons.location_on_outlined,
                  selectedIcon: Icons.location_on,
                  label: 'Check-in',
                  selected: idx == 2,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  selectedIcon: Icons.notifications,
                  label: 'Notificações',
                  selected: idx == 3,
                  badge: notificationBadgeLabel,
                  onTap: () => _onTap(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Perfil',
                  selected: idx == 4,
                  onTap: () => _onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final t = NadaTokens.of(context);
    final color = selected ? t.navActive : t.navInactive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? selectedIcon : icon, color: color, size: 24),
                if (badge != null && badge!.isNotEmpty)
                  Positioned(
                    top: -6,
                    right: -14,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : t.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: isDark ? Colors.black : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
