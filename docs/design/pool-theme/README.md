# NadaAqui — Pool Theme UX Mockups

Visual redesign draft. **Dark OLED preferred default**; light = pool-blue / water (not Twitter white).

## Tokens

See [`TOKENS.md`](./TOKENS.md) — dark + light hex for bg, surface, text, chips, FAB, nav, distance.

## Screens (1080×1920 PNG)

### Dark
- `dark-01-mapa.png` — map + filter chips + sheet
- `dark-02-ficha.png` — place detail (green distance chip)
- `dark-03-feed.png` — feed + white FAB
- `dark-04-login.png` — minimal black login
- `dark-05-cadastro.png` — signup (nome, e-mail, senha, confirmar)
- `dark-05b-cadastro-erro.png` — senha não confere

### Light
- `light-01-mapa.png`
- `light-02-ficha.png`
- `light-03-feed.png`
- `light-05-cadastro.png`
- `light-05b-cadastro-erro.png`

Sources: `_html/` + `tokens.css`.

## Logo

[`logo/`](./logo/) — SVG + PNG: app-icon, wordmark, header, mono, splash.

## Auth note

Primary flow = **password** (nome / e-mail / senha / confirmar).  
**Magic-link** (e-mail only) is a documented alternative for MVP — not mocked here.

## IA

Mapa | Feed | Check-in | Perfil. FAB → check-in / compose.  
Distance: green ≤150 · amber ≤300 · gray >300.
