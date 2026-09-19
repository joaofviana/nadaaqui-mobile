import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadaaqui/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('NadaAqui smoke', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NadaAquiApp()));
    await tester.pump();
    expect(find.textContaining('Piscinas'), findsOneWidget);
  });
}
