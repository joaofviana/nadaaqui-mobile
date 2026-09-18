import 'package:flutter_test/flutter_test.dart';
import 'package:nadaaqui/core/auth/auth_errors.dart';
import 'package:nadaaqui/data/models/auth_session.dart';

void main() {
  test('AuthSession.fromSupabase GoTrue payload', () {
    final s = AuthSession.fromSupabase({
      'access_token': 'tok',
      'refresh_token': 'ref',
      'expires_in': 3600,
      'user': {
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'email': 'qa@nadaaqui.app',
        'user_metadata': {'display_name': 'QA Tester'},
      },
    });
    expect(s.accessToken, 'tok');
    expect(s.user.email, 'qa@nadaaqui.app');
    expect(s.user.displayName, 'QA Tester');
  });

  test('authErrorPt does not leak stack', () {
    expect(
      authErrorPt('DioException [bad response]: Invalid login credentials'),
      'E-mail ou senha incorretos.',
    );
    expect(
      authErrorPt(StateError('SocketException: Failed host lookup')),
      'Falha de rede. Tente de novo.',
    );
    final generic = authErrorPt('Exception: Null check operator used on a null value');
    expect(generic, 'Não foi possível entrar. Tente de novo.');
    expect(generic.toLowerCase(), isNot(contains('null check')));
  });
}
