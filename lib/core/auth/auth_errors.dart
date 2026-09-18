/// Mensagens de Auth em PT-BR. Nunca vazar stack / JSON cru.
String authErrorPt(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('invalid login') ||
      raw.contains('invalid_grant') ||
      raw.contains('invalid credentials')) {
    return 'E-mail ou senha incorretos.';
  }
  if (raw.contains('already registered') ||
      raw.contains('user already') ||
      raw.contains('already been registered')) {
    return 'Já existe uma conta com este e-mail.';
  }
  if (raw.contains('password should be') ||
      raw.contains('password is known') ||
      raw.contains('at least 6')) {
    return 'A senha precisa ter pelo menos 6 caracteres.';
  }
  if (raw.contains('unable to validate email') ||
      raw.contains('invalid email') ||
      raw.contains('email address')) {
    return 'Confira o e-mail e tente de novo.';
  }
  if (raw.contains('email not confirmed')) {
    return 'Confirme o e-mail antes de entrar.';
  }
  if (raw.contains('socket') ||
      raw.contains('network') ||
      raw.contains('timed out') ||
      raw.contains('connection')) {
    return 'Falha de rede. Tente de novo.';
  }
  return 'Não foi possível entrar. Tente de novo.';
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
