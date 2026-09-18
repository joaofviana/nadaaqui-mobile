# API — NadaAqui mobile

**Uma fonte só.** Este repo **não** carrega YAML de contrato.

Contrato canônico (RPCs PostgREST, grants, erros JSON):

→ [`joaofviana/nadaaqui-backend` · `docs/contrato-rpc.md`](https://github.com/joaofviana/nadaaqui-backend/blob/main/docs/contrato-rpc.md)

O YAML `openapi/nadaaqui-v1.yaml` mora **só** no backend e descreve o mock REST `/v1` (WireMock). O app live **não** chama `/v1/places`.

## Caminho feliz = RPC live

```
--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co
--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

| Uso | RPC |
|---|---|
| Config | `POST /rpc/get_remote_config` |
| Lista | `POST /rpc/nearby_places` |
| Ficha | `POST /rpc/get_place` (`distanceMeters: null` — o app calcula no GPS) |
| Check-in | `POST /rpc/create_check_in` (auth) |
| Checkout | `POST /rpc/checkout_check_in` (auth) |
| Presença | `POST /rpc/who_is_here` |

## Fallback de dev = WireMock

O mock **não** está neste repo. Está em `nadaaqui-backend/mock/wiremock`.

```bash
# no clone do BACKEND (não existe pasta mock aqui, nem `cd ../mock` a partir deste repo)
cd /path/to/nadaaqui-backend
docker run --rm -p 8080:8080 \
  -v "$PWD/mock/wiremock:/home/wiremock" \
  wiremock/wiremock:3.9.1
```

Sem `SUPABASE_URL` no dart-define, o app usa `http://10.0.2.2:8080/v1` (emulador Android).
