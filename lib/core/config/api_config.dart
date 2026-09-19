/// Configuração de API do client NadaAqui.
///
/// Live: projeto `nadaaqui` (sa-east-1).
/// Anon key continua só via `--dart-define=SUPABASE_ANON_KEY` / secret CI.
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

  /// Liga PostgREST quando há URL + anon key.
  static bool get useSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static String get baseUrl {
    if (useSupabase) {
      final root = supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      return '$root/rest/v1';
    }
    return apiBaseUrl;
  }

  static const String mockScenarioHeader = 'X-Mock-Scenario';
}
