import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadaaqui/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('NadaAqui smoke - login first screen', (tester) async {
    // Testa que o app começa na tela de login quando não autenticado
    await tester.pumpWidget(
      const ProviderScope(child: NadaAquiApp()),
    );
    await tester.pump();
    
    // Deve mostrar texto da tela de login
    expect(find.textContaining('Entrar'), findsWidgets);
  });
}
