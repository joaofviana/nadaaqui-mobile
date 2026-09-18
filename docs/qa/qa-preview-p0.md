# QA estático — preview P0

**Arquivo revisado:** `mobile/preview/index.html`  
**Base:** CT-05-10, CT-02-04/08, CT-01-04/05/10, CT-04-05 e CT-06-05/08 de `criterios-teste-mvp.md`.  
**Tipo de verificação:** somente markup, CSS e JavaScript presentes no HTML; não presume UI ou comportamento que não esteja implementado.

## Chip de distância — CT-05-10 / CT-02-05

Com `R = 150 m`, a regra fechada é: verde `≤150 m`, âmbar `>150 m e ≤300 m`, cinza `>300 m`. O Teal não deve ser usado no chip de distância.

| Faixa | Classe CSS | Distâncias de exemplo no markup | Resultado estático |
|---|---|---|---|
| `≤ R` | `.chip-dist.green` | `80 m` em `#ficha`; `120 m` em `#fichaGuest` | **PASS** — verde e dentro de `≤150 m` |
| `R < d ≤ 2R` | `.chip-dist.amber` | `220 m` em `#fichaAmber` | **PASS** — âmbar e dentro de `151–300 m` |
| `d > 2R` | `.chip-dist.gray` | `450 m` em `#mapa`, `#mapaGuest` e `#fichaGray` | **PASS** — cinza e acima de `300 m` |

**Ressalva:** as classes são atribuídas manualmente no HTML. Há texto de configuração (`checkInRadiusMeters = 150`), mas não há `fetch`/cálculo que derive a classe de `GET /v1/config`; portanto a parte dinâmica/config-driven do CT não é comprovada (**FAIL de implementação comportamental**). Não há amostra exatamente em `150 m` ou `300 m` para validar as bordas inclusivas.

## GPS negado — CT-02-04 e CT-02-08

| Expectativa | Evidência | Resultado |
|---|---|---|
| Banner sticky com estado de permissão negada | `#gpsDenied .gps-banner`, “Localização desativada” e “Permissão negada” | **PASS de markup** |
| CTA para ajustes | Botão “Abrir configurações” presente | **PASS de markup** |
| Fallback à última cidade ou bairro | “São Paulo (última cidade)” e campo visual “Digite um bairro…” presentes | **PASS de markup** |
| CTA abre configurações e não repete o diálogo na sessão | O botão não possui `onclick` nem implementação correspondente no script; não há estado de sessão/permissão | **FAIL** |
| Mapa/Lista continuam utilizáveis no fallback | A tela contém mapa, mas não há tela/lista no HTML | **FAIL — cobertura apenas parcial** |

## Guest gates e “+N ocultos”

| CT | Evidência no markup | Resultado |
|---|---|---|
| CT-01-04 / CT-04-05 — mapa e ficha read-only sem login | Existem `#mapaGuest` e `#fichaGuest`, com conteúdo visível e CTA social destacado; não há login automático | **PASS para mapa/ficha representados** |
| CT-01-04 — lista read-only | Não há tela/lista guest | **FAIL — não representado** |
| CT-01-05 / CT-01-10 — gate de check-in | “Entrar para fazer check-in” em mapa e ficha guest chama `alert('Gate login...')` | **PASS de presença do gate; FAIL como fluxo de login real** |
| CT-04-05 — nenhuma ação social concluída | O HTML não persiste dados, mas também não implementa fluxo determinístico de login/cancelamento; favoritos e sugestão não aparecem | **FAIL/incompleto** |
| CT-06-05 / CT-06-08 — contador anônimo | Fichas exibem `1 pessoa · +2 ocultos`, `2 pessoas · +1 ocultos` e `3 pessoas · +2 ocultos` | **PASS** |
| Identidade dos ocultos | Avatares exibidos somente para os visíveis; ocultos aparecem apenas como `+N ocultos` | **PASS** |

O texto `3 pessoas do app estão aqui` em `#checkinDone` não é marcado como erro por si só: esse bloco não declara um cenário com ocultos, portanto não se inventa um `+N`.

## Navegação

**PASS de markup:** `.nav` usa `grid-template-columns: repeat(4, 1fr)` e contém exatamente quatro abas: **Mapa**, **Feed**, **Check-in** e **Perfil**, alinhadas ao CT-08-01 e à regra fechada de navegação. O script também atualiza a aba ativa.

## Regressões / mismatches contra regras fechadas

- **GPS:** o banner e os textos estão presentes, mas o CTA não abre ajustes, não existe controle de “1 pedido por sessão” e a condição sticky não é implementada.
- **Lista:** não há tela/lista, inclusive no contexto guest e no fallback de GPS; CTs de lista não podem ser aceitos pelo preview.
- **Guest:** o gate é apenas um `alert`, não um fluxo de login/cancelamento. O feed expõe “＋” e ações, mas não há gate guest correspondente no markup/script.
- **Distância:** as cores dos exemplos estão corretas, porém não são calculadas da configuração remota; dependem de classes escritas à mão. A tela GPS negado também não exibe o filtro `Total Pass`, presente nas demais bandas de filtro.
- **Ações de ficha:** apenas o CTA da ficha verde tem navegação para o check-in concluído; os CTAs das fichas âmbar/cinza não têm comportamento. Favoritar e sugerir correção não estão representados.

## Veredicto geral

**FAIL — não aprovado como implementação P0.** O preview passa estaticamente nas bandas de chip exemplificadas, nas quatro abas e no padrão visual de `+N ocultos`, mas falha ou não cobre comportamentos P0 essenciais: CTA/estado de GPS, lista, gate guest real e derivação das cores pela configuração remota.
