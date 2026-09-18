# API (consumo Front)

Fonte da verdade **live:** repo `nadaaqui-backend` → `docs/contrato-rpc.md`.

- App com `--dart-define=SUPABASE_URL` + `SUPABASE_ANON_KEY` → PostgREST RPCs.
- Sem defines → WireMock em `nadaaqui-backend/mock/wiremock` (`http://10.0.2.2:8080/v1` no emulador Android).

Não copie `openapi/nadaaqui-v1.yaml` para cá. Se o YAML e a RPC divergirem, a RPC ganha.
