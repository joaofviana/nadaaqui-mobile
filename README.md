# NadaAqui — client mobile (Flutter)

MVP Flutter que consome Config, Places e Check-in da API (`/v1`).

## Pré-requisitos

- Flutter SDK ≥ 3.3 (quando disponível: `flutter pub get`)
- Docker (para WireMock)

## Subir o WireMock

A partir de `../mock` (ou ajuste o volume):

```bash
cd ../mock
docker run --rm -p 8080:8080 \
  -v "$PWD/wiremock:/home/wiremock" \
  wiremock/wiremock:3.9.1
```

Base URL:

| Ambiente | URL |
|----------|-----|
| Emulador Android | `http://10.0.2.2:8080/v1` (default do app) |
| iOS Simulator / desktop | `http://localhost:8080/v1` |
| Device físico | IP da máquina host + `:8080/v1` |

## Rodar o app

```bash
cd mobile
flutter pub get

# Emulador Android (default)
flutter run

# iOS Simulator / desktop apontando para localhost
flutter run --dart-define=API_BASE_URL=http://localhost:8080/v1
```

Entrypoint: `lib/main.dart`.

## GPS de QA

Posição mock do usuário: **-23.5505, -46.6333**

| Place | UUID | Distância aprox. | Check-in esperado |
|-------|------|------------------|-------------------|
| **IN** | `11111111-1111-1111-1111-111111111111` | ~80 m | **201** OK |
| **OUT** | `22222222-2222-2222-2222-222222222222` | ~450 m | **400 OUT_OF_RANGE** |

O raio (`checkInRadiusMeters`) vem de **GET /config** — o app **não** hardcoda esse valor.

## Filtros (aba Mapa)

Chips que batem nos mappings WireMock:

1. `priceType=free` → só OUT  
2. `priceType=paid` → só IN  
3. `totalPass=yes` → só IN  

## Cenários de erro (header)

No detalhe do place, escolha o chip **X-Mock-Scenario** antes do check-in:

| Header | Efeito |
|--------|--------|
| `X-Mock-Scenario: LOCATION_STALE` | **400** localização velha |
| `X-Mock-Scenario: ALREADY_CHECKED_IN` | **409** já ativo noutro local |

## Smoke manual sugerido

1. Subir WireMock na porta 8080.  
2. Abrir app → aba **Perfil** → **Config remota** (ou `/debug/config`) → ver `checkInRadiusMeters: 150`.  
3. Aba **Mapa** → chips free/paid/totalPass.  
4. Abrir place IN → Check-in → sucesso.  
5. Abrir place OUT → Check-in → `OUT_OF_RANGE`.  
6. Repetir com chips `LOCATION_STALE` / `ALREADY_CHECKED_IN`.

## Testes unitários (parse dos fixtures)

```bash
flutter test test/models_parse_test.dart
```

Os JSON em `test/fixtures/` são cópias de `../mock/wiremock/__files/`.

## Estrutura

```
lib/
  core/config/api_config.dart
  core/network/dio_client.dart, api_error.dart
  core/session/session_store.dart
  data/models/          # RemoteConfig, Place, PlaceDetail, CheckIn, User, AuthSession…
  data/api/             # config_api, places_api, check_ins_api
  data/repositories/
  presentation/         # go_router shell: Mapa | Feed | Check-in | Perfil
main.dart
```

## UI Sprint 1 P0 (twitter-minimal)

- Theme tokens: teal `#0D9488`, chip distância **semântico** (verde/âmbar/cinza via `checkInRadiusMeters` de GET /config).
- GPS negado: 1 pedido/sessão → banner sticky “Abrir configurações” + fallback cidade + “Digite um bairro…”.
- Guest: mapa/ficha leitura livre; CTA outline **“Entrar para fazer check-in”**; presença `+N ocultos` sem inventar avatares.
- Prévia HTML (sem Flutter SDK): `preview/index.html`.

## Notas

- `google_maps_flutter` propositalmente fora do MVP scaffold.  
- Auth: interceptor Bearer lê `SessionStore`; a tela de detalhe injeta sessão mock para smoke.  
- Stubs de `android/` / `ios/` são mínimos — rode `flutter create .` no diretório para regenerar plataformas se necessário.
