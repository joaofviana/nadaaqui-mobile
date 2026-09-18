# NadaAqui — Pool Theme Tokens

Visual redesign draft. Primary identity: **dark OLED** (urubUSP-inspired). Secondary: **light pool-blue / water** (not Twitter white). Accent lineage from twitter-minimal teal, saturated for water brand.

Brand: NadaAqui — lugares para nadar (pt-BR). IA: Mapa | Feed | Check-in | Perfil.

---

## Dark (preferred default)

| Token | Hex | Notes |
|-------|-----|-------|
| `bg` | `#000000` | OLED true black |
| `bgElevated` | `#0A0A0A` | subtle lift / nav strip |
| `surface` | `#1C1C1E` | cards, inputs, sheets |
| `surface2` | `#2C2C2E` | secondary surface / inactive chip |
| `text` | `#FFFFFF` | primary |
| `textMuted` | `#8E8E93` | secondary / placeholders |
| `accent` | `#2DD4BF` | pool teal (sparingly on dark) |
| `chipActive` | `#FFFFFF` bg / `#000000` text | white pill |
| `chipInactive` | `#2C2C2E` bg / `#FFFFFF` text | dark gray pill |
| `fab` | `#FFFFFF` bg / `#000000` icon | white circle + |
| `nav` | `#000000` / `#0A0A0A` | dark bar |
| `navActive` | `#FFFFFF` | icon + label |
| `navInactive` | `#636366` | muted |
| `border` / `hairline` | `#2C2C2E` / `#1C1C1E` | separators |
| `cta` | `#8E8E93` bg / `#000000` text | login primary (ref) |
| `ctaAlt` | `#FFFFFF` bg / `#000000` text | strong CTA |

### Distance chips (on dark)

| Semantic | Text | Fill | Border |
|----------|------|------|--------|
| green ≤150 m | `#4ADE80` | `#052E16` | `#166534` |
| amber ≤300 m | `#FBBF24` | `#422006` | `#B45309` |
| gray >300 m | `#A1A1AA` | `#27272A` | `#52525B` |

---

## Light (pool blue / water)

| Token | Hex | Notes |
|-------|-----|-------|
| `bg` | `#E0F7FA` | soft cyan water |
| `bgSoft` | `#B2EBF2` | deeper water wash |
| `surface` | `#FFFFFF` | cards / sheets |
| `surface2` | `#E0F2FE` | soft blue card alt |
| `text` | `#0C4A6E` | deep pool navy |
| `textMuted` | `#0369A1` | readable blue-gray |
| `accent` | `#0284C7` | saturated pool blue |
| `accentStrong` | `#0369A1` | CTA / active nav |
| `chipActive` | `#0284C7` bg / `#FFFFFF` text | pool blue pill |
| `chipInactive` | `#FFFFFF` bg / `#0C4A6E` text / border `#7DD3FC` | |
| `fab` | `#0284C7` bg / `#FFFFFF` icon | pool blue circle |
| `nav` | `#FFFFFF` | light bar |
| `navActive` | `#0284C7` | |
| `navInactive` | `#64748B` | |
| `border` / `hairline` | `#BAE6FD` / `#E0F2FE` | |
| `cta` | `#0284C7` bg / `#FFFFFF` text | |

### Distance chips (on light)

| Semantic | Text | Fill | Border |
|----------|------|------|--------|
| green ≤150 m | `#15803D` | `#DCFCE7` | `#86EFAC` |
| amber ≤300 m | `#B45309` | `#FEF3C7` | `#FCD34D` |
| gray >300 m | `#52525B` | `#F4F4F5` | `#D4D4D8` |

---

## Shared semantics

- Filter chips (Mapa): Todos / Grátis / Pago / Total Pass
- Distance: green ≤150 · amber ≤300 · gray >300
- FAB → check-in / compose
- Auth: password flow primary; magic-link noted as alt in README
