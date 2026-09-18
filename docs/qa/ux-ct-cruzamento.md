# NadaAqui — Cruzamento CT ↔ UX mockups (twitter-minimal)

**Data:** 2026-09-17 (America/Sao_Paulo)  
**Fontes lidas:** `criterios-teste-mvp.md`, `ux-mockups/twitter-minimal/UX-NOTES.md`, HTML em `_html/` (01–04 + `shared.css`), PNGs 01–04 (confirmação visual).  
**Foco Po:** GPS denied · guest · chip 150 m (verde/âmbar/cinza) · +N ocultos · nav 4 tabs.  
**Regra:** não inventar decisão de produto — ambiguidade vira gap.

**Escopo dos mocks aprovados nesta entrega:** `01-mapa`, `02-ficha-local`, `03-feed`, `04-checkin-feito` (portrait 9:16).

**Changelog (2026-09-17 — Po locks):** G-UX-01 / G-UX-02 / G-UX-03 / G-UX-04 = **FECHADO**. Front **pode proceder** pelos CTs; mocks Ux são referência visual (não bloqueiam). G-UX-05…11 permanecem abertos (não fechados nesta passagem).

**Changelog (2026-09-17 — re-cruzamento Ux P0):** Ux entregou os mocks P0 alinhados às regras Po; **7/7 PASS**. G-UX-01..04 agora têm produto + mock visual alinhados; G-UX-05..11 permanecem abertos.

## Re-cruzamento mocks P0 (Ux 2026-09-17)

| Mock | Expectativa CT/Po | Resultado |
|---|---|---|
| 02-ficha-local 120m verde | CT-05-10 ≤150 verde | **PASS** |
| 02b 220m âmbar | ≤300 âmbar | **PASS** |
| 02c 450m cinza | >300 cinza | **PASS** |
| 01 sheet 450m cinza (if in 01-mapa) | cinza | **PASS** |
| 05-gps-negado | CT-02-04 banner sticky + Abrir configurações + fallback última cidade SP + digite bairro + distância indisponível | **PASS** |
| 01b-mapa-guest | guest leitura + Entrar para fazer check-in | **PASS** |
| 02d-ficha-guest | CTA login + “+N ocultos” (ex. 3 pessoas · +2 ocultos) | **PASS** |

---

## O que bate (CT ↔ mockup)

| # | Tema | Mockup / UX-NOTES | CT / gap fechado |
|---|---|---|---|
| M1 | Nav 4 tabs **Mapa \| Feed \| Check-in \| Perfil** (ícone + label; ativo teal `#0D9488`, inativo `#536471`) | UX-NOTES + nav idêntica em 01–04 | CT-08-01 |
| M2 | Mapa com pins na área visível (piloto SP / bairros Vila Mariana, Paraíso, Saúde) | `01-mapa` | CT-02-02, G-PILOT-CITY |
| M3 | Distância legível em m/km (“450 m”, “1,2 km”, “1,8 km”) | 01 sheet, 02 meta, 03 card check-in | CT-02-05 |
| M4 | Filtros em chips no mapa: **Todos / Grátis / Pago / Total Pass** (ativo teal) | `01-mapa` chip-row | CT-03-01/02 (Grátis/Pago); parcial vs Total Pass Aceita/Não aceita → ver G-UX-07 |
| M5 | Bottom sheet do pin: nome + distância + badges Grátis/Pago + Total Pass + rating (sem foto grande) | `01-mapa` + UX-NOTES | CT-04-01/02 (entrada pela ficha via pin) |
| M6 | Ficha: nome, distância, badges, CTA **Fazer check-in**, horário, preço, avaliação leitura | `02-ficha-local` | CT-04-01 (parcial), CT-04-04 (só Check-in visível), G-REVIEW-MVP (avaliação em leitura) |
| M7 | Presença condensada: fila de avatares + contagem (“**4** pessoas estão aqui”) | `02-ficha-local` `.who`; `02d-ficha-guest` (+N) | CT-06-01 (presença visível); CT-06-05/08 — G-UX-04 **FECHADO** |
| M8 | Tela pós check-in: **Check-in feito!** + nome do local + contagem + toggle privacidade ON + links | `04-checkin-feito` | CT-05-01/08 (sucesso), CT-07-01 (padrão visível) |
| M9 | Toggle de privacidade default **ligado** (“Mostrar meu perfil”) | `04-checkin-feito` `aria-checked="true"` | G-PRIVACY-DEFAULT / CT-07-01 (semântica; copy ≠ CT → G-UX-09) |
| M10 | Feed timeline 1 coluna: post com foto, card de check-in, ordem recente | `03-feed` + UX-NOTES | CT-08-02 (parcial: mistura posts + check-in) |
| M11 | Aba Check-in ativa na tela de sucesso | `04-checkin-feito` | CT-05-09 (atalho Check-in existe na nav) |
| M12 | Accent único teal água `#0D9488` em marca, CTA, nav ativa | UX-NOTES + `shared.css` | Alinha visual MVP (não é regra de aceite funcional) |

**Contagem de matches (linhas M\*):** **12**

---

## Gaps de aceite vs mockup (Po/Ux fechar)

### G-UX-01 — Chip de distância: cores verde / âmbar / cinza vs raio 150 m — **FECHADO**
- **ID:** G-UX-01  
- **Status:** **FECHADO** (Po 2026-09-17) — **KEEP** regra de cor (não descartar).  
- **CT/HU:** HU-05 / CT-05-10 (P0); CT-02-05 reforçado; raio via `checkInRadiusMeters` (G-RADIUS).  
- **Decisão Po (locked):**
  - **verde** se `distanceMeters` ≤ `checkInRadiusMeters` (R)
  - **âmbar** se `distanceMeters` ≤ 2 × R (e > R)
  - **cinza** se `distanceMeters` > 2 × R
  - Teal `#0D9488` **somente** nav/CTA — **não** para semântica do chip de distância
  - Front pinta a partir da config; com R=150: verde ≤150, âmbar ≤300, cinza >300
- **Mockup:** entregue no re-cruzamento Ux 2026-09-17, com cores alinhadas à regra; **produto + mock visual agora alinhados**. **Front NÃO bloqueado**.

### G-UX-02 — GPS negado: banner, copy e fallback — **FECHADO**
- **ID:** G-UX-02  
- **Status:** **FECHADO** (Po 2026-09-17) — GPS denied é **P0**.  
- **CT/HU:** CT-02-04 (P0 sticky banner + CTA settings; 1 ask/sessão), CT-02-08 (P0 CTA ajustes), CT-05-04 (P0); G-GPS-FALLBACK FECHADO.  
- **Decisão Po (locked):** sticky banner + CTA settings; **1 ask/sessão**; fallback última cidade ou “digite um bairro”. Front implementa pelos CTs; mock Ux entregue e alinhado.  
- **Mockup:** `05-gps-negado` entregue no re-cruzamento Ux 2026-09-17; **produto + mock visual agora alinhados**. **Front NÃO bloqueado**.

### G-UX-03 — Guest: CTA / gates de login visíveis — **FECHADO**
- **ID:** G-UX-03  
- **Status:** **FECHADO** (Po 2026-09-17).  
- **CT/HU:** CT-01-04/05/10 (P0), CT-04-05 (P0), CT-05-07, CT-08-03, CT-09-04, CT-10-06, CT-11-06; G-GUEST FECHADO.  
- **Decisão Po (locked):** guest = mapa/lista/ficha **read-only**; CTAs sociais **exigem login** (gate determinístico ao tocar). Front implementa; mock Ux entregue e alinhado.  
- **Mockup:** `01b-mapa-guest` e `02d-ficha-guest` entregues no re-cruzamento Ux 2026-09-17; **produto + mock visual agora alinhados**. **Front NÃO bloqueado**.

### G-UX-04 — Apresentação **+N ocultos** — **FECHADO**
- **ID:** G-UX-04  
- **Status:** **FECHADO** (Po 2026-09-17).  
- **CT/HU:** CT-06-05 (P0), CT-06-08 (P0), CT-07-02 (P0); G-HIDDEN-COUNTER FECHADO.  
- **Decisão Po (locked):** presença exibe **“+N ocultos”** **sem identidade**; N = check-ins ocultos ativos. Front implementa; mock Ux entregue e alinhado.  
- **Mockup:** `02d-ficha-guest` entregue com “+N ocultos” no re-cruzamento Ux 2026-09-17; **produto + mock visual agora alinhados**. **Front NÃO bloqueado**.

### G-UX-05 — Ficha: Favoritar e sugerir correção ausentes
- **ID:** G-UX-05  
- **CT/HU:** CT-04-04 (P0), CT-10-04, CT-11-01.  
- **Mockup mostra:** só CTA check-in + compartilhar no hero; **sem** Favoritar; **sem** sugerir correção.  
- **CT diz:** ações claras para Check-in, Favoritar e sugerir correção.  
- **Decisão sugerida:** Ux incluir ícones/links na ficha (ou menu ⋯) alinhados ao CT; guest = gate (G-UX-03).

### G-UX-06 — Tela Lista por proximidade ausente nos mocks
- **ID:** G-UX-06  
- **CT/HU:** CT-02-01, CT-02-03, CT-03-* (mapa e lista juntos).  
- **Mockup mostra:** nav **sem** aba Lista; só Mapa. UX-NOTES não descreve Lista.  
- **CT/backlog dizem:** mapa **e** lista ordenada por distância; preservar contexto ao alternar.  
- **Decisão sugerida:** (A) Lista como modo/toggle dentro de Mapa; (B) entrada pela busca; (C) adiar Lista no visual mas manter CTs — Po/Ux fechar e mockar se Must Sprint 1.

### G-UX-07 — Filtro Total Pass: um chip vs Aceita / Não aceita
- **ID:** G-UX-07  
- **CT/HU:** CT-03-03/04/09; G-TP-UNKNOWN.  
- **Mockup mostra:** um chip **“Total Pass”** (ligado/desligado implícito).  
- **CT diz:** filtros distintos **Aceita Total Pass** e **Não aceita Total Pass**; “não sei” fora de ambos.  
- **Decisão sugerida:** expandir chips/sheet de filtro no mock para bater com CT, ou relaxar CT se Po quiser um único filtro “tem Total Pass”.

### G-UX-08 — Estado “você está aqui” na ficha + checkout
- **ID:** G-UX-08  
- **CT/HU:** CT-05-08, CT-06-03.  
- **Mockup mostra:** sucesso em `04`; ficha `02` sempre com “Fazer check-in” (sem estado já checked-in / checkout).  
- **CT diz:** indicação “você está aqui” na ficha; checkout manual remove da lista.  
- **Decisão sugerida:** mock de ficha com check-in ativo (CTA vira checkout / “Você está aqui”) + fluxo checkout.

### G-UX-09 — Copy do toggle e da contagem de presença
- **ID:** G-UX-09  
- **CT/HU:** CT-07-*, CT-06-05.  
- **Mockup mostra:** “**Mostrar meu perfil**”; contagens “pessoas estão aqui” vs “pessoas **do app** estão aqui”.  
- **CT diz:** toggle “aparecer” / “oculto”; contagem “X pessoas aqui agora” + “+N ocultos”.  
- **Decisão sugerida:** unificar glossário (perfil vs presença; “do app” opcional) e atualizar CT **ou** mock — uma fonte de verdade de copy.

### G-UX-10 — Telas exigidas pelos CTs sem mock nesta entrega
- **ID:** G-UX-10  
- **CT/HU:** HU-01 (login/cadastro), HU-12 (perfil), CT-02-04 (GPS), CT-06-01 lista completa, CT-08-06 empty feed, CT-05-02 fora do raio (mensagem), CT-10 (sugerir local).  
- **Mockup mostra:** 4 telas “happy path” logado/com GPS + mocks P0 entregues de GPS denied e guest; ainda faltam os estados listados abaixo.  
- **CT diz:** vários P0 dependem desses estados.  
- **Decisão sugerida:** priorizar mocks P0 faltantes antes do Front fechar UI: GPS denied, guest gate, login, perfil+toggle, lista presença c/ +N, fora do raio, empty feed.

### G-UX-11 — Post tipo “avaliação ★★★★★” no Feed vs G-REVIEW-MVP
- **ID:** G-UX-11  
- **CT/HU:** CT-08-02 (posts + cards de check-in); G-REVIEW-MVP (criar review fora do MVP; só exibir se seed).  
- **Mockup mostra:** terceiro item do feed com estrelas + texto de review.  
- **CT diz:** feed = posts e check-ins; reviews na ficha em leitura se seed.  
- **Decisão sugerida:** tratar como post de texto com menção a local (ok) **ou** remover estrelas do feed se Po quiser evitar confusão com “criar review”.

**Contagem de gaps (G-UX-\*):** **11** total — **4 FECHADOS** (G-UX-01..04) · **7 abertos** (G-UX-05..11)

---

## CTs a adicionar/atualizar (IDs propostos)

> **2026-09-17:** G-UX-01..04 fechados → CTs abaixo **aplicados** em `criterios-teste-mvp.md`. Demais IDs aguardam fechar G-UX-05..11.

| ID | Gap | Status | Intenção |
|---|---|---|---|
| **CT-05-10** | G-UX-01 | **ADICIONADO** (P0) | Chip distância: verde ≤R / âmbar ≤2R / cinza >2R; Teal só nav/CTA; pinta de `checkInRadiusMeters` |
| **CT-02-05** | G-UX-01 | **ATUALIZADO** | Legibilidade + semântica de cor (ref. CT-05-10) |
| **CT-02-04** | G-UX-02 | **ATUALIZADO** | Sticky banner + CTA settings; 1 ask/sessão |
| **CT-02-08** | G-UX-02 | **ADICIONADO** (P0) | CTA do banner abre ajustes; sem 2º dialog na sessão |
| **CT-05-04** | G-UX-02 | **ATUALIZADO** | Check-in bloqueado sem GPS; alinhado G-UX-02 |
| **CT-01-04/05** | G-UX-03 | **ATUALIZADO** | Guest read-only; gate antes de persistir |
| **CT-01-10** | G-UX-03 | **ADICIONADO** (P0) | Gate determinístico ao tocar CTA social |
| **CT-04-05** | G-UX-03 | **ATUALIZADO** (P1→P0) | Ficha guest: CTAs pedem login |
| **CT-06-05** | G-UX-04 | **ATUALIZADO** | “+N ocultos” determinístico (ex. 4 + 2) |
| **CT-06-08** | G-UX-04 | **ADICIONADO** (P0) | Contagem ficha/sucesso com “+N ocultos” |
| **CT-07-02** | G-UX-04 | **ATUALIZADO** | Oculto entra só em +N; N incrementa |
| **CT-02-09** | G-UX-06 | pendente | Lista (ou modo lista) ordenada |
| **CT-04-07** | G-UX-05 | pendente | Favoritar + sugerir correção na ficha |
| **CT-04-08** | G-UX-08 | pendente | Ficha com check-in ativo + checkout |
| **CT-05-11** | G-UX-02 | opcional | Copy fina de bloqueio check-in sem GPS (CT-05-04 já cobre regra) |
| **CT-07-08** | G-UX-09 | pendente | Alinhar copy do toggle |
| **CT-03-10** | G-UX-07 | pendente | Chip Total Pass vs Aceita/Não aceita |

**Atualização em `criterios-teste-mvp.md` nesta passagem:** **sim** — G-UX-01..04 locked; CTs adicionados/reforçados; Front pode proceder sem mock.

---

## Pronto pro Front?

**Sim — para G-UX-01..04 (produto + mock visual alinhados; mocks P0 disponíveis).** Front **pode proceder** pelos CTs; **não** está bloqueado por mocks ausentes nestes 4.

**Pode começar (mocks P0 disponíveis + CTs locked):** shell de nav 4 tabs, mapa+pins+sheet, ficha compacta+CTA check-in, feed timeline, tela “Check-in feito!” + toggle default ON, tokens teal/hairline (M1–M12) **e**:
1. **G-UX-01 FECHADO** — chip verde/âmbar/cinza a partir de `checkInRadiusMeters` (CT-05-10); Teal só nav/CTA.  
2. **G-UX-02 FECHADO** — GPS denied P0: sticky banner + CTA settings; 1 ask/sessão (CT-02-04/08).  
3. **G-UX-03 FECHADO** — guest read-only; CTAs sociais → login (CT-01-10, CT-04-05).  
4. **G-UX-04 FECHADO** — “+N ocultos” sem identidade (CT-06-05/08).

**Ainda abertos (não bloqueiam os 4 acima; Ux/Po):** G-UX-05 (Favoritar/sugerir), G-UX-06 (Lista), G-UX-07 (filtro TP), G-UX-08 (você está aqui/checkout), G-UX-09 (copy toggle), G-UX-10 (telas faltantes), G-UX-11 (review no feed). Front pode stubar; aceite visual desses gaps continua pendente de mock/decisão.

---

## Resumo executivo (Po)

| Métrica | Valor |
|---|---|
| Path do relatório | `/workspace/nadaaqui/ux-ct-cruzamento.md` |
| Matches (M1–M12) | **12** |
| Re-cruzamento mocks P0 | **7 PASS** |
| Gaps (G-UX-01…11) | **11** (4 FECHADOS: 01..04 · 7 abertos: 05..11) |
| `criterios-teste-mvp.md` alterado? | **Sim** (2026-09-17 — CTs chip/GPS/guest/+N) |
| Pronto pro Front (G-UX-01..04)? | **Sim** — mocks P0 disponíveis; produto + visual alinhados |

### Fechados nesta passagem (Po)
1. **G-UX-01 FECHADO** — KEEP chip verde ≤R / âmbar ≤2R / cinza >2R; Teal só nav/CTA; CT-05-10.  
2. **G-UX-02 FECHADO** — GPS denied P0 sticky banner + CTA settings; 1 ask/sessão; CT-02-04/08.  
3. **G-UX-03 / G-UX-04 FECHADO** — guest read-only + gates; “+N ocultos” sem identidade; CT-01-10, CT-06-08.

### Top gaps ainda abertos
1. **G-UX-05** — Favoritar / sugerir correção na ficha.  
2. **G-UX-06** — Lista por proximidade nos mocks.  
3. **G-UX-08** — “você está aqui” + checkout na ficha.
