/// Smoke live Supabase RPCs (sem Flutter UI).
/// Uso:
///   SUPABASE_URL=... SUPABASE_ANON_KEY=... dart run tool/smoke_supabase.dart
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final url = Platform.environment['SUPABASE_URL']?.trim() ?? '';
  final key = Platform.environment['SUPABASE_ANON_KEY']?.trim() ?? '';
  if (url.isEmpty || key.isEmpty) {
    stderr.writeln('Set SUPABASE_URL and SUPABASE_ANON_KEY env vars.');
    exit(2);
  }
  final base = '${url.replaceAll(RegExp(r'/+$'), '')}/rest/v1';

  Future<Map<String, dynamic>> postRpc(
    String name,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse('$base/rpc/$name'));
      req.headers.set('apikey', key);
      req.headers.set('Authorization', 'Bearer $key');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Accept', 'application/json');
      req.add(utf8.encode(jsonEncode(body)));
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw StateError('HTTP ${res.statusCode} $name: $text');
      }
      if (text.isEmpty || text == 'null') return {};
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      if (decoded is List) {
        return {'_list': decoded, '_len': decoded.length};
      }
      return {'_raw': decoded};
    } finally {
      client.close(force: true);
    }
  }

  final cfg = await postRpc('get_remote_config', {});
  stdout.writeln('get_remote_config: $cfg');
  final radius = cfg['checkInRadiusMeters'];
  if (radius is! num) {
    stderr.writeln('FAIL: missing checkInRadiusMeters');
    exit(1);
  }

  final nearby = await postRpc('nearby_places', {
    'p_lat': -23.5505,
    'p_lng': -46.6333,
    'p_radius_meters': 50000,
    'p_limit': 5,
  });
  final list = (nearby['_list'] as List?) ?? const [];
  stdout.writeln('nearby_places count: ${list.length}');
  if (list.isEmpty) {
    stderr.writeln('FAIL: expected ≥1 place');
    exit(1);
  }
  final first = Map<String, dynamic>.from(list.first as Map);
  stdout.writeln(
    'first: ${first['name']} id=${first['id']} '
    'place_type=${first['place_type']} dist=${first['distance_meters']}',
  );

  final place = await postRpc('get_place', {
    'p_place_id': first['id'],
  });
  stdout.writeln('get_place name=${place['name']} placeType=${place['placeType']}');

  stdout.writeln('SMOKE OK');
}
