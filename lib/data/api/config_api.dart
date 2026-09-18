import 'package:dio/dio.dart';

import '../models/remote_config.dart';

/// GET /config
class ConfigApi {
  ConfigApi(this._dio);

  final Dio _dio;

  Future<RemoteConfig> getRemoteConfig() async {
    final res = await _dio.get<Map<String, dynamic>>('/config');
    return RemoteConfig.fromJson(res.data!);
  }
}
