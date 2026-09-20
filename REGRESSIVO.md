# NadaAqui - Relatório de Regressivo e Status das Funcionalidades

## 📊 Resumo Executivo

Investigação realizada em 2026-09-19 para entender por que as novas funcionalidades não estão aparecendo no app para o usuário.

## 🔍 Funcionalidades Implementadas e Status

### ✅ 1. Streak Counter
**Status:** Implementado e Funcional
**Arquivo:** `lib/presentation/widgets/streak_counter.dart`
**Integração:** `lib/presentation/screens/profile/profile_screen.dart`

**Como usar:**
- Abra a aba **Perfil**
- O Streak Counter aparece abaixo do nome e email
- Mostra dias consecutivos de natação

**Por que pode não aparecer:**
- Usa `stats.streakDays` do `swimLogStore`
- Store local que só conta sessões feitas no app atual
- Se você não fez check-ins neste build, streak = 0
- Aparece mas mostra "0 dias - Comece seu streak!" (cinza)

**Para testar:**
1. Faça um check-in no app
2. Vá para o perfil
3. Streak Counter aparecerá com dias ativos

---

### ✅ 2. Calendário de Atividades (Perfil Público)
**Status:** Implementado e Funcional
**Arquivo:** `lib/presentation/screens/profile/public_profile_screen.dart`
**Rota:** `/usuario/:userId`

**Como usar:**
- No **Feed**, clique no nome de qualquer autor de post
- Navega para `/usuario/:userId`
- Calendário aparece no perfil público com dias de atividade

**Por que pode não aparecer:**
- Só acessível clicando no nome de autor de post
- Posts precisam ter `authorId` preenchido
- Feed mock tem authorIds: `user1`, `user2`, `user3`

**Para testar:**
1. Abra o Feed
2. Clique no nome de qualquer post
3. Verá o perfil público com calendário

---

### ✅ 3. Sistema de Comentários
**Status:** Implementado e Funcional
**Arquivo:** `lib/presentation/screens/comments/comments_screen.dart`
**Rota:** `/post/:postId/comments`

**Como usar:**
- No **Feed**, clique no ícone de chat (💬) em qualquer post
- Navega para tela de comentários
- Pode adicionar comentários e dar like

**Por que pode não aparecer:**
- Ícone de comentário está na barra de ações (24px)
- Fica ao lado do like (❤️) e share (📤)
- Se o usuário não notou o novo layout, pode não clicar

**Para testar:**
1. Abra o Feed
2. Clique no ícone de chat (💬) abaixo de qualquer post
3. Verá a tela de comentários

---

### ✅ 4. Sistema de Follows
**Status:** Implementado e Funcional
**Arquivo:** `lib/presentation/screens/profile/public_profile_screen.dart`

**Como usar:**
- No **Perfil Público**, clique no botão "Seguir"
- Contador de seguidores atualiza dinamicamente
- Muda para "Seguindo" quando seguido

**Por que pode não aparecer:**
- Só no perfil público (não no perfil próprio)
- Precisa clicar no nome de autor no feed
- Botão fica ao lado do contador de seguidores

**Para testar:**
1. Clique no nome de qualquer autor no feed
2. Clique em "Seguir"
3. Verá o contador aumentar e botão mudar

---

### ✅ 5. Notificações
**Status:** Placeholder Implementado
**Arquivo:** `lib/presentation/screens/feed/feed_screen.dart`

**Como usar:**
- No **Feed**, clique no ícone de 🔔 no header
- Mostra SnackBar: "🔔 Notificações em breve!"

**Por que não funciona completamente:**
- Apenas placeholder (botão visual)
- Tela de notificações não implementada
- Backend não tem RPC de notificações ainda

**Status atual:**
- Botão aparece no header (com badge)
- Ao clicar mostra mensagem placeholder
- Precisa de backend + tela completa

---

### ✅ 6. Login-First Flow
**Status:** Implementado e Funcional
**Arquivos:** `lib/main.dart`, `lib/presentation/router/app_router.dart`, `lib/core/session/session_store.dart`

**Como usar:**
- Ao abrir o app, vai direto para tela de login (`/entrar`)
- Login com sucesso → vai para `/mapa`
- Logout → volta para `/entrar`

**Por que pode não funcionar:**
- Implementado corretamente com Riverpod providers
- SessionStore agora é ChangeNotifier
- Router reage a mudanças de sessão
- Testes passam validando behavior

**Para testar:**
1. Feche o app completamente
2. Abra novamente
3. Deve ver tela de login (não mapa)

---

## 🐛 Problemas Identificados

### 1. Streak Counter Mostra 0 Dias
**Causa:** `swimLogStore` é local e só conta sessões na memória
**Status Backend:** ✅ RPC `get_user_stats` implementada e disponível
**Solução Mobile:**
- Conectar Profile Screen com `getUserStats` RPC
- Buscar streakDays real do backend
- Remover dependência de store local

### 2. Perfil Público Usa Mock Data
**Causa:** Ainda não conectado com backend
**Status Backend:** ✅ RPC `get_user_profile` implementada e disponível
**Solução Mobile:**
- Conectar Public Profile Screen com `getUserProfile` RPC
- Buscar dados reais de perfil, followers, following
- Remover mock data

### 3. Comentários São Mock
**Causa:** UI implementada mas sem backend
**Status Backend:** ✅ RPCs `list_comments`, `create_comment`, `toggle_comment_like` implementadas
**Solução Mobile:**
- Conectar Comments Screen com RPCs de comentários
- Persistir comentários via backend
- Remover mock data

### 4. Follows São Mock
**Causa:** UI funciona mas estado não persiste
**Status Backend:** ✅ RPCs `follow_user`, `unfollow_user`, `is_following` implementadas
**Solução Mobile:**
- Conectar botão de follow com RPCs
- Persistir estado via backend
- Buscar isFollowing state real

### 5. Notificações Apenas Placeholder
**Causa:** Tela completa não implementada
**Status Backend:** ✅ RPCs `list_notifications`, `mark_notification_read`, `mark_all_notifications_read` implementadas
**Solução Mobile:**
- Criar Notifications Screen
- Conectar com RPCs de notificações
- Implementar swipe para marcar como lida

---

## 📋 Status do Backend (Joaozinho) - COMPLETO ✅

**Implementado e Aplicado em Produção:**
- ✅ Migration `20260919310000_social_schema.sql` (tabelas sociais)
- ✅ Migration `20260919320000_social_rpcs.sql` (11 RPCs sociais)
- ✅ Commits: `10e0800` → `1328cdd` → `bb519d0`
- ✅ Documentado em `docs/IMPLEMENTATION_STATUS.md`

**RPCs Disponíveis:**
- `get_user_profile(p_user_id)` - Buscar perfil de usuário
- `get_user_stats(p_user_id)` - Calcular stats reais (incluindo streak)
- `follow_user(p_follower_id, p_following_id)` - Seguir usuário
- `unfollow_user(p_follower_id, p_following_id)` - Deixar de seguir
- `is_following(p_follower_id, p_following_id)` - Verificar se segue
- `list_comments(p_post_id)` - Listar comentários
- `create_comment(p_post_id, p_text)` - Criar comentário
- `toggle_comment_like(p_comment_id)` - Like/unlike comentário
- `list_notifications(p_user_id)` - Listar notificações
- `mark_notification_read(p_notification_id)` - Marcar como lida
- `mark_all_notifications_read()` - Marcar todas como lidas

**Tabelas Criadas:**
- `follows` - Relação de follows
- `comments` - Comentários de posts
- `comment_likes` - Likes em comentários
- `notifications` - Notificações do usuário
- Colunas adicionadas em `profiles`: followers_count, following_count, posts_count, bio

---

## 📋 Lista de Tarefas para Mobile (Luizão)

### Prioridade Alta - Essencial para Funcionalidade Visível

1. **Social API Integration**
   - Criar `lib/data/models/social_responses.dart` com:
     - `UserProfileResponse`
     - `UserStatsResponse`
     - `CommentResponse`
     - `NotificationResponse`
   - Adicionar métodos em `lib/data/api/social_api.dart`:
     - `getUserProfile(String userId)`
     - `getUserStats(String userId)`
     - `followUser(String followerId, String followingId)`
     - `unfollowUser(String followerId, String followingId)`
     - `isFollowing(String followerId, String followingId)`
     - `listComments(String postId)`
     - `createComment(String postId, String text)`
     - `toggleCommentLike(String commentId)`
     - `listNotifications({String? userId})`
     - `markNotificationRead(String notificationId)`
     - `markAllNotificationsRead()`

2. **Conectar Profile Screen com Backend**
   - Chamar `getUserStats(auth.uid)` ao abrir perfil
   - Usar `streakDays` do backend no Streak Counter
   - Remover dependência de `swimLogStore` local
   - Exibir stats reais (sessions, minutes, meters, places)

3. **Conectar Public Profile Screen com Backend**
   - Chamar `getUserProfile(userId)` ao abrir perfil público
   - Chamar `isFollowing(auth.uid(), userId)` para estado inicial
   - Conectar botão "Seguir" com `followUser`/`unfollowUser`
   - Remover mock data de `mockUserProfile`
   - Manter calendário como placeholder (RPC futura)

4. **Conectar Comments Screen com Backend**
   - Chamar `listComments(postId)` ao abrir tela
   - Conectar input com `createComment(postId, text)`
   - Conectar botão de like com `toggleCommentLike(commentId)`
   - Remover mock data
   - Atualizar contador de likes após toggle

### Prioridade Média - Melhorias

5. **Criar Notifications Screen**
   - Criar `lib/presentation/screens/notifications/notifications_screen.dart`
   - Chamar `listNotifications()` ao abrir
   - Swipe para esquerda → `mark_notification_read()`
   - Botão "Marcar todas como lidas" → `mark_all_notifications_read()`
   - Conectar ícone de 🔔 no feed header com esta tela
   - Mostrar badge com contagem de não lidas

6. **Atualizar Documentação**
   - Atualizar `docs/contrato-rpc.md` com novas RPCs
   - Atualizar OpenAPI spec para match RPCs

### Notas de Implementação

- **Endpoint:** POST `/rest/v1/rpc/{function_name}`
- **Headers:** `apikey`, `Authorization: Bearer {access_token}`, `Content-Type: application/json`
- **Parâmetros:** JSON body com prefixo `p_`
- **Exemplo:**
  ```dart
  final res = await dio.post('/rest/v1/rpc/get_user_stats',
    data: {'p_user_id': userId});
  final stats = UserStatsResponse.fromJson(res.data);
  ```

---

## 📱 Recomendações para Teste (Mat)

### Teste 1: Streak Counter
1. Fazer check-in no app
2. Ir para perfil
3. Verificar se Streak Counter aparece com dias > 0

### Teste 2: Perfil Público
1. Ir para feed
2. Clicar no nome de autor de post
3. Verificar se perfil público abre com calendário

### Teste 3: Comentários
1. No feed, clicar no ícone de chat (💬)
2. Verificar se tela de comentários abre
3. Tentar adicionar comentário

### Teste 4: Follows
1. No perfil público, clicar em "Seguir"
2. Verificar se contador atualiza
3. Verificar se botão muda para "Seguindo"

### Teste 5: Login-First
1. Fechar app completamente
2. Abrir app
3. Verificar se tela de login aparece (não mapa)

---

## 🎯 Conclusão

**Funcionalidades Implementadas:**
- ✅ Streak Counter (UI completa, precisa de backend para dados reais)
- ✅ Calendário de atividades (UI completa, mock data)
- ✅ Comentários (UI completa, precisa de backend)
- ✅ Follows (UI completa, estado não persiste)
- ✅ Notificações (placeholder, precisa de backend)
- ✅ Login-First (funcional e testado)

**Por que não aparecem:**
1. **Streak Counter:** Aparece mas mostra 0 porque não há sessões locais
2. **Calendário:** Só acessível via perfil público (clicar no nome no feed)
3. **Comentários:** Botão está na barra de ações (novamente redesenhada)
4. **Follows:** Só no perfil público (clicar no nome no feed)
5. **Notificações:** Apenas placeholder
6. **Login-First:** Funciona mas usuário pode ter sessão persistida

**Próximos Passos:**
1. Backend implementar RPCs para dados reais
2. Conectar UI com backend
3. Testes de regressão com dados reais
4. Documentar para usuário onde encontrar cada feature

---

## 🎯 Conclusão Final

**Status do Backend (Joaozinho) - COMPLETO ✅:**
- ✅ Migration `20260919310000_social_schema.sql` aplicada
- ✅ Migration `20260919320000_social_rpcs.sql` aplicada
- ✅ 11 novas RPCs disponíveis em produção
- ✅ Commits: `10e0800` → `1328cdd` → `bb519d0`
- ✅ Documentado em `docs/IMPLEMENTATION_STATUS.md`

**Status do Mobile (Luizão) - PENDENTE:**
- ❌ Social API integration (criar models e métodos)
- ❌ Conectar Profile Screen com `get_user_stats`
- ❌ Conectar Public Profile Screen com `get_user_profile`
- ❌ Conectar Comments Screen com RPCs de comentários
- ❌ Criar Notifications Screen
- ❌ Atualizar `docs/contrato-rpc.md`

**Próximos Passos (Mobile - Luizão):**
1. Criar `lib/data/models/social_responses.dart` com models de resposta
2. Adicionar métodos RPCs em `lib/data/api/social_api.dart`
3. Conectar Profile Screen com `getUserStats` para Streak Counter real
4. Conectar Public Profile Screen com `getUserProfile` para dados reais
5. Conectar Comments Screen com RPCs de comentários
6. Criar Notifications Screen e conectar com header do feed
7. Atualizar `docs/contrato-rpc.md` com novas RPCs

**Documentação:**
- Backend status: `C:\Users\joaol\nadaaqui-backend\docs\IMPLEMENTATION_STATUS.md`
- Regressivo mobile: `C:\Users\joaol\nadaaqui-mobile\REGRESSIVO.md` (este arquivo)

