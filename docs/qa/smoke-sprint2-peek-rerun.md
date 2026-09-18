# Smoke Sprint 2 peek — re-run (após fix de prioridade)

| Campo | Valor |
|-------|-------|
| **Data** | 2026-09-17 22:26 BRT (America/Sao_Paulo) |
| **Base URL** | `http://localhost:8080/v1` |
| **Mock** | WireMock standalone 3.9.1 (`java -jar`), root `/workspace/nadaaqui/mock/wiremock` |
| **Docker** | Indisponível; fallback Java JAR (README pedia `docker run … wiremock/wiremock:3.9.1`) |
| **Porta** | 8080 (livre; processo encerrado ao fim) |
| **GPS mock** | -23.550500, -46.633300 |
| **Place IN** | `11111111-1111-1111-1111-111111111111` (~80 m) |
| **Place OUT** | `22222222-2222-2222-2222-222222222222` (~450 m) |
| **Contexto** | Re-teste após Backend: stubs `LOCATION_STALE` / `ALREADY_CHECKED_IN` = priority **1**; happy path place IN = priority **10** + header `X-Mock-Scenario` **absent** |

## Confirmação dos mapeamentos (pré-teste)

| Stub | Arquivo | Priority | Match relevante |
|------|---------|----------|-----------------|
| Happy path IN | `08-checkin-ok.json` | **10** | `placeId` IN + `X-Mock-Scenario` absent |
| OUT_OF_RANGE | `09-checkin-out-of-range.json` | **2** | `placeId` OUT |
| LOCATION_STALE | `10-checkin-stale.json` | **1** | header `X-Mock-Scenario: LOCATION_STALE` |
| ALREADY_CHECKED_IN | `11-checkin-already.json` | **1** | header `X-Mock-Scenario: ALREADY_CHECKED_IN` |
| Presence | `12-presence.json` | 1 | GET `/v1/places/{IN}/presence` |

Alinhado ao README (seção Prioridade WireMock).

## Resultados

| # | Passo | Esperado | Status HTTP | Resultado | Evidência |
|---|-------|----------|-------------|-----------|-----------|
| a | `POST /v1/check-ins` place IN (sem header cenário) | 201 | **201** | **PASS** | `checkIn.status: active`, `distanceMeters: 80`, `placeId` IN |
| b | `POST /v1/check-ins` place IN + `X-Mock-Scenario: LOCATION_STALE` | 4xx + LOCATION_STALE (não 201) | **400** | **PASS** | `code: LOCATION_STALE`, `details.maxAgeSeconds: 60` |
| c | `POST /v1/check-ins` place IN + `X-Mock-Scenario: ALREADY_CHECKED_IN` | 4xx + ALREADY_CHECKED_IN (não 201) | **409** | **PASS** | `code: ALREADY_CHECKED_IN`, `activePlaceId` / `activeCheckInId` presentes |
| d | `POST /v1/check-ins` place OUT | 400 OUT_OF_RANGE | **400** | **PASS** | `code: OUT_OF_RANGE`, `distanceMeters: 450`, `radiusMeters: 150` |
| e | `GET /v1/places/{IN}/presence` | 200 | **200** | **PASS** | `visibleCount: 1`, `hiddenCount: 2`, people `[Ana N.]` |

### Contagem

- **PASS:** 5/5  
- **FAIL:** 0/5  

### Falhas anteriores (smoke Sprint 1 peek)

| Cenário | Antes | Agora |
|---------|-------|-------|
| IN + `LOCATION_STALE` | **FAIL** (201 em vez de 400) | **PASS** (400 LOCATION_STALE) |
| IN + `ALREADY_CHECKED_IN` | **FAIL** (201 em vez de 409) | **PASS** (409 ALREADY_CHECKED_IN) |

## Veredito

**PASS** — o fix de prioridade do Backend funciona para os cenários IN+header. Os stubs de erro (priority 1) vencem o happy path (priority 10 + header absent); check-in feliz sem header, OUT_OF_RANGE e presence continuam ok.

## Limpeza

- WireMock **encerrado** após o re-run (`java -jar` no host; sem container Docker).
- JAR: `/workspace/nadaaqui/mock/.runtime/wiremock-standalone-3.9.1.jar`
- Porta 8080 liberada.

## Blockers

- Docker **não instalado** — usado fallback `java -jar` + OpenJDK 21. Não bloqueou o re-run.
