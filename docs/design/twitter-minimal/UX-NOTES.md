# NadaAqui — UX Notes (Twitter/X minimal)

Redesign dos mockups para direção **minimalista estilo Twitter/X**, em portrait 9:16 (Android-ish), pt-BR.

## O que mudou vs. mockups anteriores

- **Orientação:** de landscape “tablet-like” → **portrait 9:16** (1080×1920).
- **Feed:** removidos Stories/carrossel de locais e grid 2 colunas → **timeline single-column** (avatar · nome · @handle · tempo · texto · mídia opcional · ações).
- **Mapa:** bottom sheet **sem foto grande**; só nome, distância, badges em texto/pills e rating.
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
- Telas desta entrega: Mapa ativo em `01` e `02`; Feed em `03`; Check-in em `04`.

## Princípios Twitter/X aplicados

1. **Tipografia primeiro** — hierarquia por peso/tamanho, não por card shadow.
2. **Hairlines** — separadores `#EFF3F4` em vez de blocos elevados.
3. **Accent único** — teal água (`#0D9488`) só em marca, CTA, active nav e destaques semânticos.
4. **Uma coluna** — zero masonry, zero Stories.
5. **Densidade social leve** — avatares pequenos + contagem; sem carrosséis.
6. **Material-light stripped** — fundo branco, texto preto/cinza escuro, pills minimalistas.

## Arquivos

- `01-mapa.png`
- `02-ficha-local.png`
- `03-feed.png`
- `04-checkin-feito.png`

Fonte HTML de referência (para iterar): `_html/`.
