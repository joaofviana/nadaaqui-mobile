import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadaaqui/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('NadaAqui smoke - onboarding first screen', (tester) async {
    // Testa que o app começa no onboarding (/onboarding) quando não autenticado
    await tester.pumpWidget(
      const ProviderScope(child: NadaAquiApp()),
    );
    await tester.pump();
    
    // Deve mostrar a primeira tela do onboarding
    expect(find.textContaining('Conecte-se com'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);

    // Drena o timer da animação de entrada do onboarding.
    await tester.pump(const Duration(seconds: 1));
  });
}
