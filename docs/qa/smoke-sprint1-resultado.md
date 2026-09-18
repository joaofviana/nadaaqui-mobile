# Smoke Sprint 1 — NadaAqui API (WireMock)

| Campo | Valor |
|-------|-------|
| **Data** | 2026-09-17 22:04 BRT (America/Sao_Paulo) |
| **Base URL** | `http://localhost:8080/v1` |
| **Mock** | WireMock standalone 3.9.1 (`java -jar`), root `/workspace/nadaaqui/mock/wiremock` |
| **Docker** | Indisponível no ambiente; fallback Java JAR (README pedia `docker run … wiremock/wiremock:3.9.1`) |
| **Porta** | 8080 (livre) |
| **GPS mock** | -23.550500, -46.633300 |
| **Place IN** | `11111111-1111-1111-1111-111111111111` (~80 m) |
| **Place OUT** | `22222222-2222-2222-2222-222222222222` (~450 m) |

## Checklist Sprint 1

| # | Passo | Esperado | Status HTTP | Resultado | Evidência (trecho) |
|---|-------|----------|-------------|-----------|--------------------|
| a | `GET /v1/config` | 200; `checkInRadiusMeters=150`; `checkInTtlSeconds=10800` | 200 | **PASS** | `{"checkInRadiusMeters":150,"locationMaxAgeSeconds":60,"checkInTtlSeconds":10800,...}` |
| b | `GET /v1/places` (default) | 200; inclui IN e OUT | 200 | **PASS** | `items` com IN (paid, totalPass yes, 80 m) e OUT (free, totalPass no, 450 m); `total: 2` |
| c | `GET /v1/places?priceType=free` | 200; só free/OUT | 200 | **PASS** | 1 item: OUT `2222…`, `priceType: free`, `total: 1` |
| d | `GET /v1/places?priceType=paid` | 200; só paid/IN | 200 | **PASS** | 1 item: IN `1111…`, `priceType: paid`, `total: 1` |
| e | `GET /v1/places?totalPass=yes` | 200; só totalPass yes / IN | 200 | **PASS** | 1 item: IN `1111…`, `totalPass: yes`, `total: 1` |
| f1 | `GET /v1/places/{IN}` | 200; campos sensatos | 200 | **PASS** | id IN, name, address, description, `priceType: paid`, `openingHours`, `ratingAvg: 4.5` |
| f2 | `GET /v1/places/{OUT}` | 200; campos sensatos | 200 | **PASS** | id OUT, name, address, description OUT_OF_RANGE, `priceType: free` |
| g | `POST /v1/auth/login` (13-login) | 200; sessão ok | 200 | **PASS** | `accessToken: mock-access-token`, user `qa@nadaaqui.app` / `QA Tester` |

### Contagem Sprint 1

- **PASS:** 8/8  
- **FAIL:** 0/8  

### Veredito Sprint 1

**PASS** — todos os endpoints do smoke Sprint 1 responderam com status e campos-chave esperados.

---

## Peek opcional Sprint 2 (reportado à parte)

| # | Passo | Esperado | Status HTTP | Resultado | Evidência |
|---|-------|----------|-------------|-----------|-----------|
| h1 | `POST /v1/check-ins` place IN | 201 | 201 | **PASS** | `checkIn.status: active`, `distanceMeters: 80`, `placeId` IN |
| h2 | `POST /v1/check-ins` place OUT | 400 OUT_OF_RANGE | 400 | **PASS** | `code: OUT_OF_RANGE`, `distanceMeters: 450`, `radiusMeters: 150` |
| h3 | `POST /v1/check-ins` + header `X-Mock-Scenario: LOCATION_STALE` (body com placeId IN) | 400 LOCATION_STALE | **201** | **FAIL** | Stub `08-checkin-ok` venceu (mesmo priority 1 + `bodyPatterns` placeId IN); retornou check-in ativo em vez de `LOCATION_STALE` |
| h4 | `POST /v1/check-ins` + header `X-Mock-Scenario: ALREADY_CHECKED_IN` (body com placeId IN) | 409 ALREADY_CHECKED_IN | **201** | **FAIL** | Mesmo conflito de matching com `08-checkin-ok` |
| h5 | `GET /v1/places/{IN}/presence` | 200 | 200 | **PASS** | `visibleCount: 1`, `hiddenCount: 2`, people `[Ana N.]` |

**Nota h3/h4:** com `placeId` ≠ IN/OUT, os headers funcionam (`LOCATION_STALE`→400, `ALREADY_CHECKED_IN`→409). O README não deixa isso claro; mapeamentos 10/11 precisam de **priority menor que 08** (ex.: priority 1 nos headers e 5 no OK) ou exclusão mútua para o fluxo documentado com placeId IN.

### Contagem peek Sprint 2

- **PASS:** 3/5  
- **FAIL:** 2/5 (cenários por header com placeId IN)

---

## Limpeza

- WireMock **encerrado** após o smoke (processo `java -jar wiremock-standalone-3.9.1.jar` no host; não havia container Docker).
- JAR em `/workspace/nadaaqui/mock/.runtime/wiremock-standalone-3.9.1.jar` (artefato local do smoke).

## Blockers

- Docker **não instalado** — usado fallback `java -jar` + OpenJDK 21 (instalado no box para o teste). Não bloqueou o Sprint 1.
