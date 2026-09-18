import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../models/remote_config.dart';

/// Remote config: WireMock `GET /config` ou Supabase `POST /rpc/get_remote_config`.
class ConfigApi {
  ConfigApi(this._dio);

  final Dio _dio;

  Future<RemoteConfig> getRemoteConfig() async {
    if (ApiConfig.useSupabase) {
      final res = await _dio.post<Map<String, dynamic>>(
        '/rpc/get_remote_config',
        data: const <String, dynamic>{},
      );
      return RemoteConfig.fromJson(res.data!);
    }
    final res = await _dio.get<Map<String, dynamic>>('/config');
    return RemoteConfig.fromJson(res.data!);
  }
}
