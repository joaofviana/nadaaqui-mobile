import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nadaaqui/data/models/place.dart';
import 'package:nadaaqui/data/models/remote_config.dart';
import 'package:nadaaqui/data/repositories/config_repository.dart';
import 'package:nadaaqui/main.dart';
import 'package:nadaaqui/presentation/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('NadaAqui smoke', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homePlacesProvider.overrideWith((ref) async => const <Place>[]),
          remoteConfigProvider.overrideWith(
            (ref) async => const RemoteConfig(
              checkInRadiusMeters: 150,
              locationMaxAgeSeconds: 30,
              checkInTtlSeconds: 10800,
              presencePollSeconds: 15,
              citySlug: 'sao-paulo',
            ),
          ),
        ],
        child: const NadaAquiApp(),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Piscinas'), findsWidgets);
  });
}
