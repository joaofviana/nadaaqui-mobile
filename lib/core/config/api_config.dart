/// Configuração de API do client NadaAqui.
///
/// Padrão: **Supabase live** `hanqanaaimzthlqtrmks` (sa-east-1).
/// WireMock só com `--dart-define=USE_MOCK=true`.
/// Anon key via `--dart-define=SUPABASE_ANON_KEY` ou
/// `--dart-define-from-file=dart_defines.json` (gitignored).
class ApiConfig {
  ApiConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/v1',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hanqanaaimzthlqtrmks.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Opt-in no mock. Default false = tentar live.
  static const bool forceMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  static bool get missingLiveKey =>
      !forceMock && supabaseAnonKey.trim().isEmpty;

  /// Liga PostgREST no projeto live.
  static bool get useSupabase =>
      !forceMock &&
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty;

  static String get baseUrl {
    if (useSupabase) {
      final root = supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      return '$root/rest/v1';
    }
    return apiBaseUrl;
  }

  static const String projectRef = 'hanqanaaimzthlqtrmks';
  static const String dashboardUrl =
      'https://supabase.com/dashboard/project/hanqanaaimzthlqtrmks';

  static const String mockScenarioHeader = 'X-Mock-Scenario';
}
