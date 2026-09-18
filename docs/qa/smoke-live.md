# Smoke live (F7)

Pré-req: migrations + seed aplicados; app compilado com dart-defines (sem secret no git).

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

| # | Passo | Esperado | Pass/Fail |
|---|---|---|---|
| 1 | Abrir mapa guest | piscinas SP |  |
| 2 | Negar GPS | banner + fallback cidade, sem crash |  |
| 3 | Criar conta / entrar | sessão no Perfil, sem token mock |  |
| 4 | Place perto (IN) | check-in ativo |  |
| 5 | Place longe (OUT) | `OUT_OF_RANGE` + metros |  |
| 6 | Segundo local | encerra o anterior |  |
| 7 | Toggle não aparecer | some da lista, entra em hiddenCount |  |
| 8 | `select expire_check_ins()` ou esperar TTL | some da presença |  |

GPS WireMock (`-23.5505,-46.6333`) **não** vale no live. Anote place real e SHA do `main`.

Copie este arquivo para `docs/qa/smoke-live-resultado.md` ao preencher.
