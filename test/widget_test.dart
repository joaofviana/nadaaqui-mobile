import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nadaaqui/core/session/session_store.dart';
import 'package:nadaaqui/data/models/auth_session.dart';
import 'package:nadaaqui/data/models/user.dart';
import 'package:nadaaqui/main.dart';
import 'package:nadaaqui/presentation/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('NadaAqui smoke - auth redirect', (tester) async {
    final container = ProviderContainer();
    
    // No session - should redirect to login
    final router = createAppRouter(container);
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: NadaAquiApp(router: router),
      ),
    );
    await tester.pump();
    
    // Should be on login screen
    expect(find.textContaining('Entrar'), findsWidgets);
  });
}
