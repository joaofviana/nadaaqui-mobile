# NadaAqui — Critérios de teste (MVP)

**Produto:** NadaAqui — rede social de lugares para nadar (Brasil)  
**Escopo:** Android Flutter MVP (cidade piloto **São Paulo** / `sao-paulo` com seed curado; fora do MVP: Stories/Reels, chat, iOS, etc.)  
**Fonte de verdade:** `backlog-mvp.md` (HU-01 … HU-12)  
**Documento para:** Po (Joãozinho) + QA + time de refinamento  

## Como ler prioridades

Cada caso recebe **P0 / P1 / P2** combinando:

1. **Prioridade da HU** no backlog (Must → Should).
2. **Risco dentro da HU** (bloqueio de descoberta Sprint 1, presença crítica, gate guest/logado, GPS, filtros ambíguos, TTL, privacidade, sugestão pendente).

| Nível | Significado para QA |
|---|---|
| **P0** | Bloqueador de Sprint 1 (descoberta) ou caminho crítico de presença; falha impede demo ou uso básico confiável. |
| **P1** | Importante para aceite da HU; regressão grave se falhar, mas há workaround parcial. |
| **P2** | Borda, empty state, polish ou cenário raro; cobrir após P0/P1. |

**Convenções:** IDs `CT-<HU>-<nn>`. Casos em **Dado / Quando / Então** (frases completas). Onde o backlog deixa decisão aberta, o caso aponta a **Gaps** e não inventa regra de produto.

**Changelog (2026-09-17):** Po fechou G-TTL (3 h / `checkInTtlSeconds: 10800`), G-RADIUS (**150 m** inclusivo ≤ via remote config `GET /v1/config` → `checkInRadiusMeters: 150` — confirmado FECHADO), G-TWO-CHECKINS (novo encerra o anterior), G-HIDDEN-COUNTER (+N ocultos sem identidade), G-PRIVACY-DEFAULT (visível), G-TP-UNKNOWN (“não sei” fora de Aceita/Não aceita), G-GUEST (mapa/lista/ficha Must sem login), G-POST-LIMIT (280 caracteres), G-REVIEW-MVP (só exibir avaliações do seed; criar review fora do MVP) e G-GPS-FALLBACK (um pedido por sessão → banner para ajustes + última cidade ou “digite um bairro”). **Locks restantes:** G-AUTH = **Supabase** (email/senha para fixtures QA), G-PILOT-CITY = **São Paulo** (`sao-paulo`; seed SQL SP alinha com WireMock place IDs IN/OUT), G-FEED-SCOPE = **cidade piloto** only. **Smoke Sprint 1:** PASS 8/8 contra WireMock (`smoke-sprint1-resultado.md`). **Gaps abertos: nenhum.**

**Changelog (2026-09-17 — UX locks Po):** G-UX-01 FECHADO — chip de distância **verde / âmbar / cinza** a partir de `checkInRadiusMeters` (≤R verde; ≤2R âmbar; >2R cinza; Teal `#0D9488` só nav/CTA). G-UX-02 FECHADO — GPS negado = P0 sticky banner + CTA ajustes; 1 ask/sessão (Front implementa pelos CTs; mock Ux é referência visual). G-UX-03/04 FECHADO — guest mapa/lista/ficha read-only; CTAs sociais pedem login; presença mostra **“+N ocultos”** sem identidade. **Front NÃO bloqueado** por mock ausente nestes 3. CTs: CT-02-04/05 reforçados; CT-02-08, CT-05-10, CT-01-10, CT-06-08 adicionados; CT-04-05 → P0.

---

## HU-01 — Conta e sessão

**Intenção:** Visitante cria conta (Supabase Auth, email/senha), entra e mantém sessão; sem login, mapa/lista/ficha em leitura; ações sociais pedem autenticação.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-01-01 | P0 | Que estou na tela de cadastro com e-mail válido ainda não usado e senha válida | Eu confirmo o cadastro | A conta é criada via **Supabase Auth** (email/senha), eu fico autenticado e consigo acessar ações que exigem login | G-AUTH FECHADO: Supabase; path email/senha para fixtures QA |
| CT-01-02 | P0 | Que existe uma conta válida | Eu informo e-mail e senha corretos e confirmo o login | Eu entro na sessão autenticada e as abas sociais ficam liberadas | — |
| CT-01-03 | P0 | Que estou autenticado | Eu fecho o app por completo e o reabro | A sessão permanece ativa sem exigir novo login | Persistência de sessão — foco Po |
| CT-01-04 | P0 | Que estou sem sessão (visitante) | Eu abro Mapa, Lista e Ficha de um local | Eu visualizo o conteúdo em modo **somente leitura** **sem ser forçado a logar**; mapa, lista e ficha são Must no MVP para visitante; nenhum fluxo social inicia sozinho | G-GUEST / G-UX-03 FECHADO; Front implementa sem depender de mock |
| CT-01-05 | P0 | Que estou sem sessão | Eu tento check-in, favoritar, postar, curtir ou comentar | O app **interrompe** a ação **antes** de persistir qualquer dado e apresenta fluxo de login (ou mensagem clara pedindo login); mapa/lista/ficha permanecem usáveis em leitura | Gate guest vs logado; G-UX-03 FECHADO |
| CT-01-06 | P1 | Que estou autenticado | Eu escolho sair (logout) | A sessão encerra e o app volta ao modo visitante nas ações sociais | — |
| CT-01-07 | P1 | Que informo e-mail/senha inválidos | Eu tento entrar | Vejo mensagem de erro clara de credencial inválida e não entro | — |
| CT-01-08 | P1 | Que o e-mail já está cadastrado | Eu tento cadastrar de novo com esse e-mail | Vejo mensagem clara de e-mail já usado e a conta não é duplicada | — |
| CT-01-09 | P2 | Que estou na tela de cadastro/login com campos vazios ou senha abaixo do mínimo (se houver regra) | Eu tento submeter | O app impede o envio e indica o problema no formulário | Detalhe de validação de formulário |
| CT-01-10 | P0 | Que estou sem sessão na ficha, no Feed ou em ação social (check-in / + post / curtir / comentar / favoritar / sugerir) | Eu toco no CTA social | O gate de login é apresentado de forma clara e **determinística** (ex.: sheet/bottom “Entrar para continuar” ou equivalente); **nenhuma** ação social é concluída; ao cancelar o gate, volto ao contexto read-only | G-UX-03 FECHADO; Front implementa pelos CTs (mock Ux = referência visual) |

---

## HU-02 — Mapa e lista por proximidade

**Intenção:** Com GPS autorizado, ver locais próximos no mapa e na lista ordenada por distância; sem GPS, pedir permissão e fallback.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-02-01 | P0 | Que o GPS está autorizado e há seed de locais na área da cidade piloto **São Paulo** (`sao-paulo`) | Eu abro a Lista | Os locais aparecem ordenados por distância crescente (“mais perto de mim”); seed SQL SP alinha com WireMock place IDs IN/OUT | G-PILOT-CITY FECHADO: São Paulo; caminho crítico Sprint 1 |
| CT-02-02 | P0 | Que o GPS está autorizado e há locais na área visível (piloto SP) | Eu abro o Mapa | Pins dos locais da área visível são exibidos no mapa | G-PILOT-CITY FECHADO |
| CT-02-03 | P0 | Que estou na Lista com contexto de localização definido | Eu alterno para Mapa e depois de volta para Lista | O contexto de localização é preservado (mesma referência de proximidade) | — |
| CT-02-04 | P0 | Que a permissão de localização foi negada (ou já foi pedida nesta sessão) | Eu abro Mapa/Lista | O app **não** repete o dialog de permissão na mesma sessão (**1 ask/sessão**); exibe **banner sticky** com **CTA para abrir ajustes** (settings) e oferece fallback para a **última cidade** usada **ou** o campo **“digite um bairro”**; mapa/lista seguem usáveis com esse contexto | G-GPS-FALLBACK / G-UX-02 FECHADO: sticky banner + CTA settings; Front NÃO bloqueado por mock ausente |
| CT-02-05 | P1 | Que um local está a ~350 m e outro a ~2,1 km e `checkInRadiusMeters` = **150** | Eu visualizo a lista ou a distância na ficha/card | As distâncias aparecem de forma legível (ex.: “350 m”, “2,1 km”); o chip de distância usa a semântica de cor de **CT-05-10** (com R=150: ~350 m → **âmbar**; ~2,1 km → **cinza**); Teal `#0D9488` **não** pinta o chip de distância | G-UX-01 FECHADO; ver CT-05-10 |
| CT-02-06 | P1 | Que o GPS está autorizado mas a precisão é baixa (impreciso) | Eu abro lista/mapa e observo ordenação/distâncias | O app não trava; distâncias refletem a posição reportada e, se houver aviso de precisão, ele é compreensível; o fluxo de GPS negado permanece o de CT-02-04 (não se aplica aqui) | Risco GPS impreciso — distinto do fallback de permissão negada |
| CT-02-07 | P2 | Que não há locais na área visível / seed vazio na região | Eu abro mapa ou lista | Há empty state ou mensagem amigável sem crash | — |
| CT-02-08 | P0 | Que o GPS foi negado nesta sessão e o banner sticky de GPS está visível | Eu toco no CTA do banner | O sistema abre (ou direciona para) as **configurações/ajustes** de permissão de localização; o banner permanece sticky até a permissão ser concedida ou o user sair do contexto; **não** há segundo dialog de permissão do SO na mesma sessão | G-UX-02 FECHADO; assertiva de UI do CTA settings; Front implementa pelos CTs |

---

## HU-03 — Filtros Grátis / Pago / Total Pass

**Intenção:** Filtrar por preço e Total Pass de forma combinável; mapa e lista atualizam juntos; “não sei” não entra em Aceita nem Não aceita.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-03-01 | P0 | Que existem locais Grátis e Pago no seed | Eu ativo o filtro Grátis | Mapa e lista mostram apenas locais Grátis | Combinações Grátis/Pago |
| CT-03-02 | P0 | Que existem locais Pago no seed | Eu ativo o filtro Pago | Mapa e lista mostram apenas locais Pago | — |
| CT-03-03 | P0 | Que existem locais com Total Pass = sim, não e não sei | Eu ativo “Aceita Total Pass” | Apenas locais com Total Pass = sim aparecem; os “não sei” **não** entram em Aceita | G-TP-UNKNOWN FECHADO: “não sei” fora de Aceita e Não aceita |
| CT-03-04 | P0 | Que existem locais com Total Pass = sim, não e não sei | Eu ativo “Não aceita Total Pass” | Apenas locais com Total Pass = não aparecem; os “não sei” **não** entram em Não aceita | Idem |
| CT-03-05 | P0 | Que há locais Grátis que aceitam Total Pass e outros que não | Eu combino Grátis + Aceita Total Pass | Só permanecem locais que satisfazem **ambos** os critérios | Combinação clara |
| CT-03-06 | P1 | Que apliquei um ou mais filtros | Eu limpo todos os filtros | Mapa e lista voltam ao conjunto completo de locais da área | — |
| CT-03-07 | P1 | Que filtros estão ativos na Lista | Eu alterno para Mapa e depois para Lista | O estado dos filtros permanece e o resultado continua filtrado | — |
| CT-03-08 | P1 | Que apliquei filtros que não deixam nenhum local | Eu observo mapa e lista | Empty state coerente (sem crash) e opção clara de limpar filtros | — |
| CT-03-09 | P2 | Que um local tem Total Pass = “não sei” e nenhum filtro Total Pass ativo | Eu visualizo o conjunto completo | O local “não sei” aparece normalmente no conjunto sem filtro Total Pass; só some dos resultados quando Aceita ou Não aceita está ativo | G-TP-UNKNOWN FECHADO |

---

## HU-04 — Ficha do local

**Intenção:** Abrir ficha completa a partir do pin ou da lista para decidir a visita; campos ausentes como “não informado”; CTAs de Check-in, Favoritar e sugerir correção; avaliações só em leitura se o seed tiver (criar review fora do MVP).

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-04-01 | P0 | Que um local do seed tem nome, endereço, tipo, preço, Total Pass e demais campos preenchidos | Eu abro a ficha pelo pin do mapa | A ficha exibe nome, endereço, tipo, preço aproximado, Total Pass (sim/não/não sei), horários (se houver), fotos e, **se o seed tiver**, avaliações em **somente leitura** | G-REVIEW-MVP FECHADO: sem criar review no MVP |
| CT-04-02 | P0 | Que o mesmo local aparece na Lista | Eu abro a ficha pelo item da lista | A mesma ficha do local é aberta com os mesmos dados | — |
| CT-04-03 | P1 | Que um local tem campos opcionais ausentes (horário, foto, avaliação, preço) | Eu abro a ficha | Campos ausentes aparecem como “não informado” (ou equivalente) e a tela não quebra; se não houver avaliações no seed, não há CTA de criar avaliação | Criar review fora do MVP |
| CT-04-04 | P0 | Que estou autenticado na ficha | Eu observo as ações disponíveis | Há ação clara para Check-in, Favoritar e sugerir correção | Guest: check-in/favorito/sugerir pedem login (HU-01) |
| CT-04-05 | P0 | Que estou sem sessão na ficha | Eu observo e aciono Check-in / Favoritar / sugerir correção | A ficha permanece **somente leitura** e legível; ao acionar qualquer CTA social, o gate de login aparece e **nenhuma** ação social é concluída | G-UX-03 FECHADO; alinhado CT-01-10 |
| CT-04-06 | P2 | Que o local tem Total Pass = “não sei” | Eu abro a ficha | O valor Total Pass é exibido de forma explícita como “não sei” (não como sim nem não) | Alinha com HU-03 |

---

## HU-05 — Check-in com validação GPS

**Intenção:** Usuário logado só faz check-in dentro do raio GPS de **150 m** (≤ inclusivo, remote config); fora do raio e sem GPS o fluxo bloqueia com orientação; no máximo um check-in ativo (novo check-in encerra o anterior).

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-05-01 | P0 | Que estou logado, GPS autorizado e estou **dentro** do raio de **150 m** do local (ex.: ~80 m no place IN do mock) | Eu confirmo o check-in | O check-in é aceito; a ficha indica que eu estou aqui e eu apareço em “quem está aqui” (respeitando privacidade HU-07) | G-RADIUS FECHADO: 150 m (≤); config `checkInRadiusMeters: 150` |
| CT-05-02 | P0 | Que estou logado, GPS autorizado e estou **fora** do raio de **150 m** (ex.: ~450 m no place OUT do mock) | Eu tento fazer check-in | O app explica que estou fora do raio, **não** registra check-in e não altera presença | Alinha mock README place OUT |
| CT-05-03 | P0 | Que estou logado e a distância calculada ao local é **exatamente 150 m** (borda inclusiva) | Eu tento check-in | O check-in é **aceito** porque a regra é **≤ 150 m**; se a distância for **> 150 m**, é rejeitado com mensagem clara | G-RADIUS FECHADO: inclusivo (≤ 150 m) |
| CT-05-04 | P0 | Que estou logado mas a permissão/GPS está indisponível (negado ou desligado) | Eu inicio o fluxo de check-in | O fluxo é **bloqueado** com orientação clara para habilitar GPS/permissão (alinhada ao banner/CTA de G-UX-02 quando aplicável); **nenhum** check-in é criado | GPS obrigatório; G-UX-02 FECHADO |
| CT-05-05 | P0 | Que estou logado com GPS impreciso (accuracy ruim) perto do local | Eu tento check-in | O app aplica a mesma regra **≤ 150 m** com a posição reportada; não cria check-in fraudulento silencioso; se houver bloqueio por precisão, a mensagem é clara | Mesmo raio de G-RADIUS; sem limiar extra inventado |
| CT-05-06 | P0 | Que já tenho um check-in ativo em outro local | Eu confirmo check-in em um segundo local válido (**≤ 150 m**) | O sistema **encerra o check-in anterior** e registra o novo; passo a aparecer só no local novo | G-TWO-CHECKINS FECHADO; raio 150 m |
| CT-05-07 | P1 | Que estou sem sessão | Eu tento check-in pela ficha ou pelo atalho Check-in | Sou levado ao login e nenhum check-in é criado | Gate guest |
| CT-05-08 | P1 | Que acabei de fazer check-in com sucesso | Eu abro a ficha do local | Vejo indicação “você está aqui” (ou equivalente) no meu próprio app | — |
| CT-05-09 | P2 | Que o atalho da aba Check-in aponta para o local mais próximo | Eu uso o atalho com GPS ok e distância **≤ 150 m** do mais próximo | O fluxo de check-in desse local é iniciado de forma coerente com a ficha | Navegação mockada; raio 150 m |
| CT-05-10 | P0 | Que o Front pintou o chip de distância a partir de `GET /v1/config` → `checkInRadiusMeters` (= **R**; MVP seed R=**150**) e há locais com `distanceMeters` nas faixas ≤R, ≤2R e >2R (ex.: ≤150, ≤300, >300) | Eu visualizo o chip de distância no mapa/lista/ficha/card | O chip é **verde** se `distanceMeters` ≤ R; **âmbar** se R < `distanceMeters` ≤ 2×R; **cinza** se `distanceMeters` > 2×R; Teal `#0D9488` **não** é usado para semântica do chip (só nav/CTA); com R=150: verde ≤150, âmbar ≤300, cinza >300 | G-UX-01 FECHADO — **KEEP** regra de cor; Front pinta da config; mock = referência visual |

---

## HU-06 — Quem está aqui agora

**Intenção:** Listar presença ativa (TTL **3 h**), expirar automaticamente, permitir checkout manual e manter contagem coerente com privacidade (+N ocultos).

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-06-01 | P0 | Que há check-ins ativos recentes no local (dentro do TTL de 3 h) | Eu abro a ficha / seção “quem está aqui” | A lista mostra as presenças ativas visíveis (não ocultas por identidade) | TTL = 3 h (G-TTL FECHADO) |
| CT-06-02 | P0 | Que meu check-in está ativo há **3 horas** (`checkInTtlSeconds: 10800`) sem checkout manual | O TTL de **3 horas** se esgota | Meu check-in some da lista de presença ativa automaticamente | G-TTL FECHADO: 3 h; checkout manual continua removendo na hora |
| CT-06-03 | P0 | Que tenho check-in ativo | Eu faço checkout manual | Sou removido imediatamente da lista “quem está aqui” e deixo de estar “aqui” na ficha | — |
| CT-06-04 | P1 | Que a lista já estava aberta e outro usuário fez check-in | Eu puxo para atualizar (ou reabro a ficha) | A lista reflete a presença atualizada | Realtime vs polling é nota técnica |
| CT-06-05 | P0 | Que há usuários ocultos e visíveis com check-in ativo (ex.: 4 visíveis e 2 ocultos) | Eu (outro usuário) vejo a lista e a contagem de presença | Identidades ocultas **não** aparecem com nome/avatar na lista; a UI exibe de forma **determinística** o total anônimo como **“+N ocultos”** (ex.: “4 pessoas · +2 ocultos” ou equivalente com o N correto); N = quantidade de check-ins ocultos ativos | G-HIDDEN-COUNTER / G-UX-04 FECHADO; Front implementa pelos CTs |
| CT-06-06 | P1 | Que não há ninguém com presença ativa | Eu abro “quem está aqui” | Empty state amigável (zero pessoas) sem erro | — |
| CT-06-07 | P2 | Que um check-in está a poucos minutos de completar 3 h | Eu aguardo a expiração e atualizo | Antes das 3 h o usuário ainda aparece; após o TTL de 3 h some automaticamente | TTL = 3 h |
| CT-06-08 | P0 | Que a ficha (ou tela pós check-in) mostra a contagem de presença e existem check-ins ocultos ativos | Eu leio a contagem de “quem está aqui” | A contagem inclui a indicação **“+N ocultos”** sem revelar identidade; se N=0, não inventar “+0 ocultos” de forma confusa (omitir ou mostrar coerente); avatares/nomes só dos visíveis | G-UX-04 FECHADO; Front NÃO bloqueado por mock ausente |

---

## HU-07 — Privacidade no check-in

**Intenção:** Toggle para ocultar presença; lista reflete na hora; o próprio usuário sempre vê seu check-in ativo.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-07-01 | P0 | Que estou logado e o toggle está em “aparecer” (visível) — padrão do MVP | Eu faço check-in e outro usuário abre “quem está aqui” | Meu nome/avatar aparece na lista visível | G-PRIVACY-DEFAULT FECHADO: padrão = visível |
| CT-07-02 | P0 | Que estou com toggle “oculto” e check-in ativo | Outro usuário abre “quem está aqui” | Eu **não** apareço com nome/avatar na lista; entro apenas no total anônimo como parte de **“+N ocultos”** (sem identidade); o N incrementa em 1 relativo ao cenário sem mim oculto | G-HIDDEN-COUNTER / G-UX-04 FECHADO |
| CT-07-03 | P0 | Que tenho check-in ativo visível | Eu mudo o toggle para oculto durante o check-in | A lista de outros usuários deixa de mostrar minha identidade imediatamente (após refresh/realtime) | — |
| CT-07-04 | P0 | Que tenho check-in ativo oculto | Eu mudo o toggle para visível | Passo a aparecer com identidade na lista dos outros | — |
| CT-07-05 | P0 | Que estou oculto com check-in ativo | Eu abro a ficha / presença no **meu** app | Continuo vendo meu próprio check-in ativo normalmente | “Sempre mostra para mim” |
| CT-07-06 | P1 | Que ainda não fiz check-in | Eu altero o toggle de privacidade no perfil e depois faço check-in | O check-in respeita o estado do toggle escolhido antes | — |
| CT-07-07 | P2 | Que crio uma conta nova | Eu abro o toggle de privacidade de check-in | O valor inicial é **visível** (“aparecer”) | G-PRIVACY-DEFAULT FECHADO |

---

## HU-08 — Feed leve

**Intenção:** Aba Feed com posts e cards de check-in da **cidade piloto** em ordem cronológica inversa; post exige login; empty state amigável.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-08-01 | P1 | Que o app está aberto | Eu navego pelas abas | Existe a aba Feed na navegação (Mapa \| Feed \| Check-in \| Perfil) | — |
| CT-08-02 | P1 | Que há posts e check-ins recentes no escopo da **cidade piloto** (São Paulo) | Eu abro o Feed | Vejo mistura de posts (foto e/ou texto) e cards de check-in **somente da cidade piloto**, em ordem cronológica inversa | G-FEED-SCOPE FECHADO: cidade piloto only |
| CT-08-03 | P0 | Que estou sem sessão | Eu tento criar um post | Sou direcionado ao login e nenhum post é publicado | Gate guest |
| CT-08-04 | P1 | Que estou logado | Eu publico um post com texto de até **280** caracteres e sem foto | O post aparece no topo do feed (ordem inversa) | G-POST-LIMIT FECHADO: 280 caracteres |
| CT-08-05 | P1 | Que estou logado | Eu publico um post com texto válido e **uma** foto | O post é criado com a foto e aparece no feed | MVP: 1 foto |
| CT-08-06 | P1 | Que ainda não há conteúdo no feed | Eu abro a aba Feed | Vejo empty state amigável | — |
| CT-08-07 | P2 | Que informo texto com **mais de 280** caracteres | Eu tento publicar | O app impede a publicação e indica o limite de **280** caracteres | G-POST-LIMIT FECHADO |

---

## HU-09 — Curtir e comentar

**Intenção:** Logado curte/descurte e comenta; visitante vai ao login; autor pode apagar o próprio comentário.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-09-01 | P1 | Que estou logado e vejo um post/check-in sem minha curtida | Eu toco em curtir | A curtida é registrada e a contagem aumenta | — |
| CT-09-02 | P1 | Que já curti o item | Eu toco novamente (descurtir) | A curtida é removida e a contagem diminui | Toggle |
| CT-09-03 | P1 | Que estou logado | Eu envio um comentário de texto dentro do limite | O comentário aparece na lista (mais recentes) | — |
| CT-09-04 | P0 | Que estou sem sessão | Eu tento curtir ou comentar | Sou levado ao login; curtida/comentário não são criados | Gate guest |
| CT-09-05 | P1 | Que eu sou autor de um comentário | Eu apago meu comentário | O comentário some da lista | — |
| CT-09-06 | P2 | Que outro usuário comentou | Eu (não autor) tento apagar o comentário dele | Não consigo apagar o comentário alheio | Segurança básica |
| CT-09-07 | P2 | Que o texto do comentário excede o limite | Eu tento enviar | O envio é bloqueado com indicação do limite | Limite a confirmar no refinamento |

---

## HU-10 — Sugerir local / atualizar Total Pass e preço

**Intenção:** Logado sugere local novo ou correção; sugestão fica pendente até moderação; status visível; pendente **não** vai ao mapa público.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-10-01 | P1 | Que estou logado | Eu inicio “sugerir local” e preencho nome, tipo, pin no mapa, Grátis/Pago e Total Pass | A sugestão é enviada com status “enviada/pendente” | — |
| CT-10-02 | P0 | Que enviei uma sugestão de local novo ainda **pendente** | Eu (ou outro usuário) consulto o mapa/lista públicos | O local pendente **não** aparece no mapa público | Foco Po — pending vs approved |
| CT-10-03 | P0 | Que a curadoria **aprovou** a sugestão | Eu consulto mapa/lista | O local passa a aparecer no mapa público com os dados aprovados | — |
| CT-10-04 | P1 | Que estou na ficha de um local logado | Eu sugiro correção de Total Pass e/ou preço | A correção fica pendente de moderação e não altera a ficha pública imediatamente | — |
| CT-10-05 | P1 | Que tenho sugestões em diferentes estados | Eu abro perfil/histórico de sugestões | Vejo status enviada / aprovada / rejeitada de forma clara | — |
| CT-10-06 | P0 | Que estou sem sessão | Eu tento sugerir local ou correção | O app pede login e não cria sugestão | Gate guest |
| CT-10-07 | P2 | Que a curadoria rejeitou minha sugestão | Eu consulto o status | Aparece como rejeitada e o mapa público permanece inalterado | — |

---

## HU-11 — Favoritos

**Intenção:** Logado favorita/desfavorita na ficha; lista no perfil; persiste entre sessões; remoção sincroniza com a ficha.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-11-01 | P1 | Que estou logado na ficha de um local não favoritado | Eu toco em Favoritar | O local fica marcado como favorito | — |
| CT-11-02 | P1 | Que o local está favoritado | Eu abro a lista de favoritos no perfil | O local aparece na lista | — |
| CT-11-03 | P0 | Que tenho favoritos salvos | Eu faço logout, login de novo (ou mato o app e reabro com sessão persistente) | Os favoritos continuam associados à conta | Persistência — foco Po |
| CT-11-04 | P1 | Que removo o local da lista de favoritos | Eu abro a ficha do mesmo local | O estado na ficha reflete “não favorito” (sincronizado) | — |
| CT-11-05 | P1 | Que desfavorito pela ficha | Eu abro a lista de favoritos | O local não aparece mais na lista | — |
| CT-11-06 | P0 | Que estou sem sessão | Eu tento favoritar | Sou levado ao login; favorito não é criado | Gate guest |

---

## HU-12 — Perfil básico

**Intenção:** Perfil com nome/apelido, foto opcional, toggle de privacidade, acesso a favoritos e sugestões, logout e edição mínima.

| ID | Prioridade | Dado | Quando | Então | Observação |
|---|---|---|---|---|---|
| CT-12-01 | P1 | Que estou logado (conta nova ou com padrão intacto) | Eu abro Perfil | Vejo nome/apelido, foto (se houver) e o toggle de privacidade de check-in com padrão **visível** | G-PRIVACY-DEFAULT FECHADO; liga HU-07 |
| CT-12-02 | P1 | Que estou no perfil | Eu acesso Favoritos e Minhas sugestões | Consigo abrir ambas as seções a partir do perfil | — |
| CT-12-03 | P0 | Que estou logado | Eu escolho Logout | A sessão encerra e ações sociais passam a exigir login | Alinha CT-01-06 |
| CT-12-04 | P1 | Que estou no perfil | Eu edito nome/apelido e (opcionalmente) a foto e salvo | As alterações persistem ao reabrir o perfil | Edição mínima MVP |
| CT-12-05 | P2 | Que estou sem foto | Eu abro o perfil | Há placeholder coerente sem quebrar o layout | — |
| CT-12-06 | P2 | Que mudo o toggle de privacidade no perfil | Eu faço check-in depois | A presença respeita o novo estado do toggle | Cruzamento HU-07 |

---

## Gaps de aceite (Po fechar nas HUs)

Gaps **FECHADOS** já refletem nos “Então” dos CTs afetados. **Não há gaps abertos** — todos os itens da tabela abaixo estão FECHADOS (Po 2026-09-17).

| ID | HU | Status / decisão | Impacto no teste | Pergunta objetiva para o Po (se aberto) |
|---|---|---|---|---|
| **G-GPS-FALLBACK** | HU-02 | **FECHADO:** um pedido de permissão por sessão; depois **banner sticky** + CTA ajustes + fallback **última cidade** ou **“digite um bairro”** (G-UX-02) | CT-02-04/08, CT-05-04 | — |
| **G-RADIUS** | HU-05 | **FECHADO:** raio = **150 m** inclusivo (≤), via remote config `GET /v1/config` (`checkInRadiusMeters: 150`); chip distância (G-UX-01): verde ≤R / âmbar ≤2R / cinza >2R | CT-05-01/02/03/05/06/09/10, CT-02-05 | — |
| **G-TWO-CHECKINS** | HU-05 | **FECHADO:** novo check-in **encerra o anterior** | CT-05-06 atualizado | — |
| **G-TTL** | HU-06 | **FECHADO:** presence TTL = **3 horas** (`checkInTtlSeconds: 10800` em `GET /v1/config`); checkout manual remove na hora | CT-06-01/02/07 atualizados | — |
| **G-HIDDEN-COUNTER** | HU-07 / HU-06 | **FECHADO:** ocultos entram no total anônimo como **“+N ocultos”**, **sem identidade** na lista (G-UX-04) | CT-06-05/08, CT-07-02 | — |
| **G-PRIVACY-DEFAULT** | HU-07 / HU-12 | **FECHADO:** padrão do toggle = **visível** | CT-07-01/07, CT-12-01 atualizados | — |
| **G-FEED-SCOPE** | HU-08 | **FECHADO:** escopo = **cidade piloto** only | CT-08-02 atualizado | — |
| **G-TP-UNKNOWN** | HU-03 | **FECHADO:** “não sei” fica **fora** de Aceita e de Não aceita | CT-03-03/04/09 confirmados | — |
| **G-AUTH** | HU-01 | **FECHADO:** **Supabase** Auth; path **email/senha** para fixtures QA | CT-01-01 atualizado; setup de contas de teste via email/senha | — |
| **G-GUEST** | HU-01 | **FECHADO:** mapa/lista/ficha **Must** read-only sem login; CTAs sociais pedem login (G-UX-03) | CT-01-04/05/10, CT-04-05 | — |
| **G-POST-LIMIT** | HU-08 | **FECHADO:** limite = **280** caracteres | CT-08-04/07 atualizados | — |
| **G-PILOT-CITY** | transversal | **FECHADO:** **São Paulo** (`sao-paulo`); seed SQL SP alinha com WireMock place IDs IN/OUT | CT-02-01/02 e smoke Sprint 1 atualizados | — |
| **G-REVIEW-MVP** | HU-04 | **FECHADO:** **só exibir** avaliações se o seed tiver; **criar review fora do MVP** | CT-04-01/03 e notas atualizados | — |

---

## Smoke checklist (opcional)

### Sprint 1 — Descoberta (HU-01 … HU-04)

**Resultado API (WireMock, 2026-09-17):** smoke Sprint 1 **PASS 8/8** — ver `smoke-sprint1-resultado.md`.

1. Instalar build Android; abrir app sem login → mapa/lista/ficha legíveis na cidade piloto **São Paulo** (CT-01-04, CT-02-01/02; G-PILOT-CITY).  
2. Negar GPS → um pedido por sessão; banner **sticky** + CTA ajustes + última cidade ou “digite um bairro” (CT-02-04/08; G-UX-02).  
3. Autorizar GPS → lista ordenada por distância; distâncias legíveis.  
4. Filtrar Grátis, Pago, Aceita TP, Não aceita TP; limpar filtros; “não sei” fora dos filtros TP (CT-03-*).  
5. Abrir ficha por pin e por lista; campos ausentes = “não informado”.  
6. Cadastrar/logar via **Supabase** (email/senha), matar app, reabrir → sessão persistente (CT-01-01/03; G-AUTH).  
7. Visitante tenta check-in/favoritar → login (gates).

### Sprint 2 — Presença (HU-05 … HU-07)

1. Logado + GPS dentro de 150 m (ex.: ~80 m place IN) → check-in ok; “você está aqui” + lista de presença.  
2. Fora do raio (ex.: ~450 m place OUT) e borda ≤150 m → rejeição / aceite inclusivo.  
3. GPS negado no check-in → bloqueio com orientação.  
4. Segundo check-in → encerra o anterior (CT-05-06).  
5. Checkout manual remove da lista; após TTL de 3 h some sozinho (CT-06-02).  
6. Toggle oculto: some da lista dos outros; total anônimo mostra “+N ocultos” (CT-06-05/08); eu ainda me vejo.
6b. Chip distância: com R=150, verde ≤150 / âmbar ≤300 / cinza >300; Teal só nav/CTA (CT-05-10; G-UX-01).  
7. Alternar toggle durante check-in ativo → lista reflete na hora.

---

## Contagem rápida (referência QA)

| HU | Casos | P0 | P1 | P2 |
|---|---|---|---|---|
| HU-01 | 10 | 6 | 3 | 1 |
| HU-02 | 8 | 5 | 2 | 1 |
| HU-03 | 9 | 5 | 3 | 1 |
| HU-04 | 6 | 4 | 1 | 1 |
| HU-05 | 10 | 7 | 2 | 1 |
| HU-06 | 8 | 5 | 2 | 1 |
| HU-07 | 7 | 5 | 1 | 1 |
| HU-08 | 7 | 1 | 4 | 2 |
| HU-09 | 7 | 1 | 4 | 2 |
| HU-10 | 7 | 3 | 3 | 1 |
| HU-11 | 6 | 2 | 4 | 0 |
| HU-12 | 6 | 1 | 3 | 2 |
| **Total** | **91** | **45** | **32** | **14** |

*Documento atualizado com decisões Po de 2026-09-17 (G-RADIUS = 150 m; G-AUTH / G-PILOT-CITY / G-FEED-SCOPE; **G-UX-01/02/03/04** chip cores / GPS sticky / guest / +N ocultos). **Gaps abertos: nenhum.** Smoke Sprint 1: PASS 8/8 (WireMock). Front **não** bloqueado por mocks ausentes de G-UX-01..04.*
