# NadaAqui — HOME IA (piscinas)

Screen: **06 Home / Piscinas próximas**  
Themes: dark OLED + light pool-blue  
Mocks: `dark-06-home-piscinas.html|.png`, `light-06-home-piscinas.html|.png`  
Structure ref: `refs/urubusp-home-notif.png` (layout only — NadaAqui brand, not USP)

## Brand (LOCKED)

- Official logo **#4** kit: `logo/mark.png` + `logo/wordmark-dark.png` (see `logo/BRAND.md` / `official/`)
- Dark HOME header: **`wordmark-dark.png`** full lockup (mark + word on OLED)
- Light HOME header: **`mark.png`** + text “NadaAqui”
- Do not invent alternate marks/mascots; do not stack mark + wordmark PNGs (wordmark already includes mark)

## Tab bar (5) — LOCKED

| # | Tab | Notes |
|---|-----|-------|
| 1 | **Mapa** | Active on HOME (discovery / nearby) |
| 2 | **Feed** | Social timeline |
| 3 | **Check-in** | Place check-in |
| 4 | **Notificações** | Badge **9+** (overflow) |
| 5 | **Perfil** | Account |

Replaces prior 4-tab IA (Mapa \| Feed \| Check-in \| Perfil).

## HOME layout (top → bottom)

1. **Status bar** — time / network / battery  
2. **App bar** — official mark + NadaAqui  
3. **Search** — “Buscar piscinas, bairro ou #tag…”  
4. **Carousel card — “Piscinas próximas”** (primary)  
5. **Perto de você** — horizontal cards + “ver todas”  
6. **Em alta** — ranked local trends  
7. **FAB** — compose / check-in (+)  
8. **Tab bar** — 5 items above

## Card carousel — “Piscinas próximas” (LOCKED fields)

Controls: **← arrows →** + **dots** (page index).

Per slide, show:

| Field | Example / enum |
|-------|----------------|
| Nome | Municipal Vila Mariana |
| Distância | chip gray/amber/green (tokens) |
| **Tipo** | Olímpica · Semi-olímpica · Recreativa · … |
| **Presença** | `vazio` \| `pouca gente` \| `cheio` + **count** (“N na água”) |
| Amenities | **Coberta** / **Aquecida** (badges when true) |
| Acesso | **Grátis** \| **Pago** \| **Total Pass** (badges) |
| Footer (optional) | relatos · comentários |

Presence color: green = vazio · amber = pouca gente · red = cheio.

## Secondary modules

- **Perto de você** — compact cards (thumb + nome + distância/tipo + presença + acesso)
- **Em alta** — numbered keywords (bairro / tag / produto) + activity count

## Tokens

Reuse `_html/tokens.css` — `.theme-dark` / `.theme-light`.  
Nav override on this screen: `grid-template-columns: repeat(5, 1fr)`.

## Render

```bash
google-chrome --headless --disable-gpu --hide-scrollbars --window-size=1080,1920 \
  --screenshot=dark-06-home-piscinas.png \
  file://…/_html/dark-06-home-piscinas.html
# same for light-06-home-piscinas
```

Output size: **1080×1920**.
