# CHANGELOG — Home IA / tab bar

## 2026-09-17 (PT)

### Approved
- Joãozinho **approved** home remock: `dark-06-home-piscinas` + `light-06-home-piscinas`.
- Locked 5-tab bar: **Mapa | Feed | Check-in | Notificações (badge 9+) | Perfil**.
- Brand remains official logo **#4** (mark / wordmark); no brand changes.

### Propagated tab bar
Replaced prior 4-tab IA on remaining main-chrome screens (HTML + 1080×1920 PNG):

| Screen | Active tab |
|--------|------------|
| `dark-01-mapa` / `light-01-mapa` | Mapa |
| `dark-02-ficha` / `light-02-ficha` | Mapa |
| `dark-03-feed` / `light-03-feed` | Feed |

- No dedicated check-in screen in pool-theme — skipped.
- Auth left without main tabbar: `dark-04-login`, `dark-05-cadastro` (+ error / light cadastro variants).
- `dark-06` / `light-06` kept as approved (tabbar already locked).

### Shared / tokens
- `tokens.css`: `.nav` → `repeat(5, 1fr)`; shared `.nav-badge` (dark white / light `#0284C7`).
- New partial: `_html/_partials/tabbar.html` (locked markup reference).
