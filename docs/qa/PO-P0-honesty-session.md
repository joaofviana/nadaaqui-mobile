# PO brief — P0 honesty + session (Felipe Nobre)

Source: Mat regression (NÃO APROVADO). Lane: **front**. Owner: **Luizão**. QA: **Mat**. Carol: copy only if Luizão needs empty-state wording. Joaozinho: **no SQL** — RPCs already exist.

PR (English): `feat(app): stop fake data and persist session`

## Stories

### NA-P0-01 — Customer copy when live is off
As a swimmer I want a human message if the server is unreachable, so I don't see Flutter commands.
**AC:** Banner does not mention `dart_defines.json`, `flutter run`, or dashboard URL. Copy in PT: we couldn't reach NadaAqui; try again later. LIVE/MOCK/OFF badge hidden unless `kDebugMode`.

### NA-P0-02 — Hide QA from production UI
**AC:** "QA WireMock" expansion on place detail only in `kDebugMode`. Profile does not show "Config remota / GET /config". That screen stays at `/debug/config` only.

### NA-P0-03 — Ficha shows address and description
**AC:** Place detail renders `address` and `description` when present (Sesc maintenance, SEME, phone).

### NA-P0-04 — Notifications copy
**AC:** No word "stub". Empty state: "Nenhuma notificação por enquanto."

### NA-P0-05 — HOME does not lie
**AC:** Request GPS once on HOME (same helper as explorar). Distance chip uses remote config radius, never hardcoded 150. If distance is null/0 without a real GPS fix, show unavailable — not green 0 m. Do not hardcode presence empty/0; omit presence row or fetch `who_is_here` for visible cards. "Em alta" hidden when empty.

### NA-P0-06 — Session survives kill
**AC:** Persist `AuthSession` (access + refresh + user) with `shared_preferences`. Restore on launch. `Sair` clears storage. Do not log tokens.

### NA-P0-07 — Hydrate active check-in
**AC:** On launch if logged in, call `getActiveCheckIn()` and restore Check-in tab. Privacy switch must not pretend to persist until `update_my_profile` is wired — if not wired this PR, hide the switch or label it as local-only is **not** OK; hide it.

### NA-P0-08 — Feed uses live RPC when live
**AC:** If `ApiConfig.useSupabase`, feed loads `SocialApi.listFeed`. Compose/kudo call create/toggle RPCs. No seed "Lagoa Azul" / "Piscina Municipal" on live. Guest kudo goes through login gate. If RPC fails, empty state in PT, not fake people.

## Out of scope
iOS icon, splash PNG, map pins neighborhood names, bairro search geocoding, photo-in-compose, LGPD, light theme.

## Git
Branch from `main`: `feat/app-honesty-session`. PR title/body **English**.
