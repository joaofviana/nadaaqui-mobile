/// Textos legais in-app (PT-BR) para Play Store / uso produtivo.
/// Versão 1.0 — 27/09/2026. Atualize a data ao alterar o conteúdo.

abstract final class LegalTexts {
  static const privacyVersion = '1.0';
  static const termsVersion = '1.0';
  static const effectiveDate = '27 de setembro de 2026';

  static const privacyTitle = 'Política de Privacidade';
  static const termsTitle = 'Termos de Uso';

  static const privacyBody = '''
Última atualização: $effectiveDate (versão $privacyVersion)

O NadaAqui (“nós”, “aplicativo”) é um serviço focado em natação: encontrar locais para nadar, registrar sessões e interagir com a comunidade.

1. Controlador dos dados
Os dados são tratados pelo operador do aplicativo NadaAqui. Para exercer direitos ou tirar dúvidas: use a opção “Excluir conta” no app ou o canal de suporte indicado na ficha do app na loja.

2. Dados que coletamos
• Conta: e-mail, nome de exibição e senha (a senha é armazenada de forma criptografada pelo provedor de autenticação).
• Localização: quando você autoriza, usamos GPS para listar piscinas próximas e validar check-in. A localização não é usada para anúncios de terceiros.
• Uso do app: check-ins, sessões de nado (duração, metros quando informados), publicações, avaliações, participação em clubes e eventos.
• Dados técnicos: identificadores de sessão, logs de erro e informações do dispositivo necessárias para segurança e estabilidade.

3. Finalidades
• Prestar o serviço (mapa, check-in, feed, treinos, clubes).
• Segurança da conta e prevenção a abuso.
• Cumprir obrigações legais.
• Melhorar o produto com base em falhas e uso agregado (quando aplicável).

4. Base legal (LGPD)
Tratamos dados com base em execução de contrato (prestação do app), legítimo interesse (segurança e melhoria) e consentimento (quando exigido, como permissão de localização no sistema).

5. Compartilhamento
Não vendemos seus dados. Podemos usar provedores de infraestrutura (hospedagem, autenticação, banco de dados) sob contrato, apenas para operar o NadaAqui. Conteúdo que você publica (posts, avaliações, presença em clubes) pode ser visível a outros usuários conforme as configurações do produto.

6. Retenção
Mantemos os dados enquanto sua conta existir e pelo tempo necessário às finalidades acima ou exigências legais. Ao excluir a conta, removemos ou anonimizamos os dados pessoais associados, ressalvadas retenções legais mínimas.

7. Seus direitos
Você pode solicitar acesso, correção, portabilidade (quando aplicável) e exclusão da conta pelo próprio aplicativo (Perfil → menu → Conta e privacidade → Excluir conta).

8. Crianças
O app não se destina a menores de 13 anos. Não coletamos dados de crianças de forma consciente.

9. Alterações
Podemos atualizar esta política. A data no topo indica a versão vigente. Uso continuado após mudanças relevantes constitui ciência, quando permitido pela lei.

10. Contato
Dúvidas sobre privacidade: utilize o e-mail de suporte publicado na página do app na loja de aplicativos.
''';

  static const termsBody = '''
Última atualização: $effectiveDate (versão $termsVersion)

Ao criar uma conta ou usar o NadaAqui, você concorda com estes Termos.

1. O serviço
O NadaAqui oferece ferramentas para descobrir locais de natação, registrar atividades, publicar conteúdo e participar de clubes/eventos. O serviço é oferecido “como está”, podendo evoluir ou ter funcionalidades em teste.

2. Conta
Você é responsável por manter a confidencialidade da senha e por atividades na sua conta. Informe dados verdadeiros. Uma conta por pessoa.

3. Uso aceitável
É proibido: assediar outros usuários; publicar conteúdo ilegal, ofensivo ou que viole direitos de terceiros; tentar invadir o sistema; manipular check-ins ou rankings de forma fraudulenta; usar o app para spam.

4. Conteúdo do usuário
Você mantém direitos sobre o que publica. Ao publicar, concede ao NadaAqui licença para exibir e distribuir esse conteúdo no app e em materiais de divulgação do produto. Podemos remover conteúdo que viole estes Termos.

5. Locais e segurança
Informações de piscinas e horários podem estar incompletas. Você é responsável pela própria segurança na prática da natação e pelo cumprimento das regras de cada estabelecimento.

6. Exclusão de conta
Você pode excluir a conta a qualquer momento em Perfil → Conta e privacidade → Excluir conta. A exclusão é irreversível e remove dados pessoais associados, na medida descrita na Política de Privacidade.

7. Limitação
Na extensão permitida pela lei, não nos responsabilizamos por danos indiretos, perda de dados por falha de rede do usuário, ou uso indevido do app por terceiros.

8. Alterações e rescisão
Podemos alterar os Termos com aviso no app ou na loja. Podemos suspender contas que violem estes Termos.

9. Lei aplicável
Estes Termos são interpretados conforme as leis do Brasil, sem prejuízo de direitos do consumidor inderrogáveis.
''';
}
