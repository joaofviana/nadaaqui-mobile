# Smoke live — ponta a ponta (F7)

O que o PO roda. **Caminho feliz = RPC live**, não WireMock.

GPS de QA (`-23.5505, -46.6333`) serve **só** para WireMock.
No live, anote o place real (ex.: SESC Ipiranga / CE Ipiranga) e a distância medida.

## 0. Pré

1. Backend: migrations + seed Ipiranga aplicados no projeto live.
2. App com dart-defines (**nunca** commitados):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

3. Smoke RPC sem UI:

```bash
SUPABASE_URL=... SUPABASE_ANON_KEY=... dart run tool/smoke_supabase.dart
```

Esperado: `get_remote_config` + `nearby_places` ≥ 1 place do seed.

## Roteiro (10 linhas)

| # | Passo | Esperado |
|---|---|---|
| 1 | Backend migrations + seed Ipiranga no live | 10 places publicados |
| 2 | App com dart-defines | sobe sem crash |
| 3 | Abrir mapa **guest** | ver piscinas de SP |
| 4 | Negar GPS | banner + fallback cidade, **não crasha** |
| 5 | Login (e-mail/senha) | sessão real; Perfil mostra e-mail |
| 6 | Place perto (IN) | 201/OK check-in |
| 7 | Place longe (OUT) | `OUT_OF_RANGE` com metros |
| 8 | Segundo check-in noutro lugar | encerra o anterior |
| 9 | Toggle “não aparecer” | some da lista, entra em `hiddenCount` |
| 10 | Esperar TTL **ou** `select expire_check_ins()` | some da presença |

Resultado: preencher [`smoke-live-resultado.md`](smoke-live-resultado.md).
