import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadaaqui/main.dart';

void main() {
  testWidgets('NadaAqui smoke', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NadaAquiApp()));
    await tester.pump();
    expect(find.textContaining('Piscinas'), findsOneWidget);
  });
}
