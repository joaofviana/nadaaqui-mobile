# NadaAqui — UX Notes (Twitter/X minimal)

Redesign dos mockups para direção **minimalista estilo Twitter/X**, em portrait 9:16 (Android-ish), pt-BR.

## O que mudou vs. mockups anteriores

- **Orientação:** de landscape “tablet-like” → **portrait 9:16** (1080×1920).
- **Feed:** removidos Stories/carrossel de locais e grid 2 colunas → **timeline single-column** (avatar · nome · @handle · tempo · texto · mídia opcional · ações).
- **Mapa:** bottom sheet **sem foto grande**; só nome, distância (chip semântico), badges e rating.
- **Ficha do local:** hero **compacto**; “Quem está aqui” virou **linha de avatares + contagem** (não card); horário/preço/avaliação em **lista com hairlines**.
- **Check-in feito:** fundo branco esparso (sem foto full-bleed); check teal + tipografia; ações em **links de texto**, não cards empilhados.
- **Sombras/cards pesados:** quase eliminados; divisores finos e whitespace.

## Regras de navegação (iguais em todas as telas)

| Tab       | Label    | Ativo = teal |
|-----------|----------|--------------|
| 1         | Mapa     | ícone mapa   |
| 2         | Feed     | ícone lista  |
| 3         | Check-in | ícone pin    |
| 4         | Perfil   | ícone pessoa |

- Bottom nav **sempre idêntica** (ícones + labels).
- Estado ativo: cor **#0D9488**; inativos: cinza `#536471`.
- Telas desta entrega: Mapa ativo em `01`, `01b`, `02*`, `05`; Feed em `03`; Check-in em `04`.

## Princípios Twitter/X aplicados

1. **Tipografia primeiro** — hierarquia por peso/tamanho, não por card shadow.
2. **Hairlines** — separadores `#EFF3F4` em vez de blocos elevados.
3. **Accent único** — teal água (`#0D9488`) só em marca, CTA logado, active nav e destaques de marca (não no chip de distância).
4. **Uma coluna** — zero masonry, zero Stories.
5. **Densidade social leve** — avatares pequenos + contagem; sem carrosséis.
6. **Material-light stripped** — fundo branco, texto preto/cinza escuro, pills minimalistas.

---

## P0 QA — regras entregues nesta iteração

### 1) Chip de distância (Ficha + bottom sheet do mapa)

**NÃO usar teal fixo.** Cor semântica por `distanceMeters`:

| Faixa | Cor | Chip CSS | Tokens sugeridos |
|-------|-----|----------|------------------|
| ≤ 150 m (raio de check-in) | **Verde** | `.chip-dist.green` | texto `#16A34A`, bg `#DCFCE7`, borda `#86EFAC` |
| ≤ 300 m | **Âmbar/laranja** | `.chip-dist.amber` | texto `#D97706`, bg `#FEF3C7`, borda `#FCD34D` |
| > 300 m | **Cinza** | `.chip-dist.gray` | texto `#6B7280`, bg `#F3F4F6`, borda `#D1D5DB` |

- Mesmo chip no **mapa bottom sheet** quando a distância é exibida.
- Sem GPS / distância indisponível: texto muted “distância indisponível” (não inventar número).
- Variantes Front/QA: `02` = 120 m verde · `02b` = 220 m âmbar · `02c` = 450 m cinza · `01` sheet = 450 m cinza.

### 2) GPS negado / localização off (CT-02-04 · G-GPS-FALLBACK)

- **Uma** solicitação de permissão por sessão; se negada → banner persistente + fallback.
- Banner sticky sob o app bar: copy clara (“Localização desativada” / permissão negada).
- CTA primário do banner: **“Abrir configurações”**.
- Mapa/lista continuam usáveis com fallback: **última cidade** + campo **“Digite um bairro…”**.
- Bottom nav intacta (Mapa ativo). Distância no sheet some / fica “indisponível”.
- Mock: `05-gps-negado.png`.

### 3) Estados guest (mapa + ficha)

- Guest **lê** mapa/ficha normalmente.
- CTAs sociais (check-in, favorito, post, etc.) → **login**:
  - CTA outline/secundário: **“Entrar para fazer check-in”** (não CTA teal sólido de check-in).
- Bloco de presença:
  - Contagem anônima de ocultos como **“+N ocultos”**.
  - **Nunca** inventar avatar/nome para ocultos.
  - Ex.: “**3** pessoas · +2 ocultos” com só avatares dos visíveis.
- Mocks: `01b-mapa-guest.png`, `02d-ficha-guest.png`.

---

## Arquivos (PNG 1080×1920)

| Arquivo | Estado |
|---------|--------|
| `01-mapa.png` | Mapa logado; sheet com chip distância cinza (450 m) |
| `01b-mapa-guest.png` | Mapa guest + CTA “Entrar para fazer check-in” |
| `02-ficha-local.png` | Ficha · chip **verde** 120 m |
| `02b-ficha-ambar.png` | Ficha · chip **âmbar** 220 m |
| `02c-ficha-cinza.png` | Ficha · chip **cinza** 450 m |
| `02d-ficha-guest.png` | Ficha guest · outline CTA + “+2 ocultos” |
| `03-feed.png` | Feed (inalterado nesta P0) |
| `04-checkin-feito.png` | Check-in feito (inalterado nesta P0) |
| `05-gps-negado.png` | GPS negado · banner + settings + fallback |

Fonte HTML: `_html/` (`shared.css` inclui `.chip-dist.*`, `.cta-outline`, `.gps-banner`).
