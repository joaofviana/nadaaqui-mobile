import 'package:flutter/material.dart';

import 'nadaaqui_mark.dart';

/// Lockup oficial: mark vetorial + "NadaAqui".
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return NadaAquiBrand(height: height);
  }
}
