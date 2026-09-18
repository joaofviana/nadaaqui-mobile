/// Configuração de API do client NadaAqui.
///
/// Preferência:
/// 1. Se `SUPABASE_URL` (dart-define) estiver setado → PostgREST RPCs ao vivo.
/// 2. Senão, `API_BASE_URL` (WireMock / mock local).
///
/// Emulador Android WireMock: 10.0.2.2 aponta para o host da máquina.
/// iOS Simulator / desktop: use localhost via --dart-define.
///
/// Secrets (anon key) só via --dart-define / CI secrets — nunca commitados.
class ApiConfig {
  ApiConfig._();

  /// WireMock / OpenAPI `/v1` base (fallback quando Supabase não está configurado).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/v1',
  );

  /// Projeto Supabase (ex.: https://xxxx.supabase.co). Vazio = desligado.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Anon key do projeto — apenas via `--dart-define=SUPABASE_ANON_KEY=...`.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// true quando URL Supabase foi injetada no build.
  static bool get useSupabase => supabaseUrl.trim().isNotEmpty;

  /// Base Dio: `{SUPABASE_URL}/rest/v1` ou WireMock `/v1`.
  static String get baseUrl {
    if (useSupabase) {
      final root = supabaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
      return '$root/rest/v1';
    }
    return apiBaseUrl;
  }

  /// Header opcional para forçar cenários WireMock (LOCATION_STALE / ALREADY_CHECKED_IN).
  static const String mockScenarioHeader = 'X-Mock-Scenario';
}
