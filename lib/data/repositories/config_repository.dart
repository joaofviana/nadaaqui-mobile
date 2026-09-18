import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../api/config_api.dart';
import '../models/remote_config.dart';

class ConfigRepository {
  ConfigRepository(this._api);

  final ConfigApi _api;

  Future<RemoteConfig> fetch() => _api.getRemoteConfig();
}

final configApiProvider = Provider<ConfigApi>((ref) {
  return ConfigApi(ref.watch(dioProvider));
});

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository(ref.watch(configApiProvider));
});

/// Cache leve da config remota (raio, max-age, etc.). Nunca hardcode o raio.
final remoteConfigProvider = FutureProvider<RemoteConfig>((ref) async {
  return ref.watch(configRepositoryProvider).fetch();
});
