part of 'onboarding_screen.dart';

abstract final class _Ob {
  static const teal = Color(0xFF2DD4BF);
  static const tealDeep = Color(0xFF0F766E);
  static const ink = Color(0xFF042F2E);
  static const card = Color(0xFFF8FAFC);
}

class _BrandMarkCompact extends StatelessWidget {
  const _BrandMarkCompact();

  @override
  Widget build(BuildContext context) {
    return const NadaAquiBrand(height: 28, color: Colors.white);
  }
}
