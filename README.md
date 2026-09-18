# NadaAqui — Mobile (Flutter)

App Android-first do NadaAqui (Mapa | Feed | Check-in | Perfil).

## Estrutura

- `lib/` — código Flutter
- `docs/design/` — mockups UX
- `docs/qa/` — critérios/smokes
- `docs/api/` — OpenAPI de consumo
- `preview/` — prévia HTML das telas (smoke visual sem SDK)

## Stack

Flutter + Dart, Dio, Riverpod, go_router. UI Sprint 1: twitter-minimal (`#0D9488`).

## Mock local

```bash
# WireMock (a partir do repo backend/mock)
# Base URL emulador Android: http://10.0.2.2:8080/v1

flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/v1
```

## GPS QA

`-23.5505, -46.6333` · place IN `11111111-1111-1111-1111-111111111111` · OUT `22222222-2222-2222-2222-222222222222`
