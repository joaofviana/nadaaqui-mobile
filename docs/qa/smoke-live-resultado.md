# Smoke live — resultado

| Campo | Valor |
|---|---|
| Data | 2026-09-18 |
| SHA `main` | `ce56f02` (`feat(api): live Supabase RPCs + hide fake notif badge`) |
| Ambiente | construtor (GitHub PRs F0–F8; sem device físico neste ciclo) |
| Place live usado | _a preencher no campo — ex. CE Ipiranga `952f671d-…`_ |
| Distância medida | _a preencher_ |

GPS WireMock (`-23.5505, -46.6333`) **não** vale para as linhas 6–8 live.

| # | Passo | Resultado | Notas |
|---|---|---|---|
| 1 | Migrations + seed Ipiranga no live | pending | aplicar PRs backend F2/F3 no projeto |
| 2 | App com dart-defines | pending | precisa Flutter SDK + defines locais |
| 3 | Mapa guest → piscinas SP | pending | |
| 4 | Negar GPS → banner + cidade | pending | |
| 5 | Login real | pending | PR mobile #6 (`feat/f5-auth`) |
| 6 | Place perto → OK | pending | GPS real, PR #7 |
| 7 | Place longe → OUT_OF_RANGE + metros | pending | |
| 8 | 2º check-in encerra o anterior | pending | |
| 9 | “não aparecer” → hiddenCount | pending | toggle já no perfil/check-in se existir |
| 10 | expire_check_ins → some da presença | pending | SQL no README backend F3 |

**Este ciclo (construtor):** F0 mergeu tema+live no `main`. PRs F1–F8 abertas. Device/SQL live **não** rodaram aqui (sem `SUPABASE_ANON_KEY` no git, sem emulador).

PO: marcar pass/fail por linha na próxima corrida de campo e atualizar SHA se o `main` avançar.
