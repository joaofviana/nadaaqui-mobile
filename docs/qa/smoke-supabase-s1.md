# Smoke Sprint 1 — NadaAqui LIVE Supabase (não WireMock)

| Campo | Valor |
|-------|-------|
| **Data** | 2026-09-18 00:02 BRT (America/Sao_Paulo) |
| **Alvo** | LIVE Supabase `https://hanqanaaimzthlqtrmks.supabase.co` |
| **Auth** | Guest/anon (`SUPABASE_ANON_KEY` via `/workspace/nadaaqui-backend/.env.local`) — chave **não** impressa |
| **GPS QA** | -23.5505, -46.6333 |
| **Canal** | PostgREST RPC (`/rest/v1/rpc/...`) |
| **Ref doc** | `nadaaqui-backend/docs/supabase-live.md` + migrations `20260917220300_rpcs` / `20260918001000_fix_nearby_places` |

## Checklist

| # | Passo | Esperado | HTTP | Resultado | Evidência |
|---|-------|----------|------|-----------|-----------|
| 1 | `get_remote_config` | 200; `checkInRadiusMeters=150`; `checkInTtlSeconds=10800` (3h) | 200 | **PASS** | `{"citySlug":"sao-paulo","checkInTtlSeconds":10800,"checkInRadiusMeters":150,"presencePollSeconds":30,"locationMaxAgeSeconds":60}` |
| 2 | `nearby_places` lat/lng QA, radius 50 km | ~10 published; inclui IN / OUT / âmbar | 200 | **PASS** | `total_count=10`, 10 rows; IN `1111…` 49 m, âmbar `3333…` 219 m, OUT `2222…` 425 m + 7 Ipiranga |
| 3 | `get_place` id IN | 200; ficha publicada | 200 | **PASS** | name `Piscina Clube Centro`, `placeType:pool`, `priceType:paid`, `totalPass:yes`, address/description/openingHours/ratingAvg 4.50 |
| 4 | `who_is_here` place IN (presence peek) | 200; shape presence | 200 | **PASS** | `{"placeId":"1111…","visibleCount":0,"hiddenCount":0,"people":[]}` (vazio ok — sem check-ins ativos) |
| 5 | `create_check_in` anon | auth gate (não 500) | 400 | **PASS (gate)** | `{"code":"P0001","message":"UNAUTHORIZED"}` — RPC só `GRANT … TO authenticated`; anon bloqueado como esperado |

## Contagens nearby (10 published)

| Dist (m) | Nome | price | totalPass | id (prefix) |
|----------|------|-------|-----------|-------------|
| 49 | Piscina Clube Centro (IN) | paid | yes | `11111111` |
| 219 | Piscina QA Âmbar (~220 m) | free | unknown | `33333333` |
| 425 | Praia Artificial Parque (OUT) | free | no | `22222222` |
| 3225 | Soul Beach Arena | paid | no | `c6d37240` |
| 4316 | Clube Atlético Ypiranga (CAY) | paid | unknown | `63657e49` |
| 4322 | Centro Esportivo Ipiranga – Balneário Carlos Joel Nelli | free | no | `952f671d` |
| 4533 | Sesc Ipiranga | paid | no | `b90aa544` |
| 5055 | Academia Training UP | paid | unknown | `c93fcb17` |
| 5616 | Aqua School (Go Now Alto do Ipiranga) | paid | unknown | `553d0911` |
| 6845 | Centro Esportivo Vila Carioca – Balneário Princesa Isabel | free | no | `fc042c45` |

## Contagem

- **PASS:** 5/5 (item 5 = PASS com gate de auth)
- **FAIL:** 0/5

## Veredito overall

**PASS** — Sprint 1 API smoke + presence peek contra LIVE Supabase OK. Config (raio 150 / TTL 3h), ~10 places com IN/OUT/âmbar, ficha `get_place`, presence peek `who_is_here`, e `create_check_in` corretamente gated para authenticated (sem 500 inesperado).

## Notas

- Sem secrets no relatório (anon key omitida).
- Presence vazia é esperado em ambiente live sem check-ins ativos de QA.
- Cópia também em `nadaaqui-mobile-repo/docs/qa/smoke-supabase-s1.md` quando aplicável.
