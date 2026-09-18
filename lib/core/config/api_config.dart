/// Configuração de API do client NadaAqui.
///
/// Emulador Android: 10.0.2.2 aponta para o host da máquina.
/// iOS Simulator / desktop: use localhost via --dart-define.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/v1',
  );

  /// Header opcional para forçar cenários WireMock (LOCATION_STALE / ALREADY_CHECKED_IN).
  static const String mockScenarioHeader = 'X-Mock-Scenario';
}
