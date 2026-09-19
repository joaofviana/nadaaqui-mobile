# NadaAqui mobile

Contexto da squad (o que o produto é e o que já foi feito): `C:\Users\joaol\.grok\agents\_nadaaqui-context.md` (cópia em `docs/SQUAD-CONTEXT.md` no backend e no mobile).
Git Flow + PRs in English: `docs/GIT-FLOW.md`. Template: `.github/PULL_REQUEST_TEMPLATE.md`.

PO da squad: **Felipe Nobre** (`felipe-nobre`). Toda task passa por ele antes de código.
UX: **Carol** (`carol-ux`). Ela desenha as telas mobile.
Android/mobile: **Luizão** (`luizao`). Flutter + pasta `android/` (Manifest, Gradle, APK).
QA: **Mat** (`mat`). Escreve e roda testes (`flutter test` / analyze). Não implementa feature.
Backend: **Joaozinho** (`joaozinho`) no repo `nadaaqui-backend` (Supabase/RPC/WireMock). Não invente RPC neste repo.

Frontend Flutter/Dart. Delegate UI, routing, Riverpod, Dio, and screen work to the `nadaaqui-frontend` agent.

- Repo: https://github.com/joaofviana/nadaaqui-mobile
- Agent: `.grok/agents/nadaaqui-frontend.md`
- Stack: Flutter 3.3+, Riverpod, go_router, Dio, Supabase RPC or WireMock
- Do not add `google_maps_flutter`. Theme via `NadaTokens.of(context)`.
- Tests: `flutter analyze` and `flutter test`
