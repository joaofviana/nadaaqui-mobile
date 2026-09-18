/// Lê campo camelCase ou snake_case de um mapa JSON (WireMock vs PostgREST).
dynamic jsonPick(Map<String, dynamic> json, String camel, [String? snake]) {
  if (json.containsKey(camel) && json[camel] != null) return json[camel];
  final s = snake ?? _camelToSnake(camel);
  if (json.containsKey(s) && json[s] != null) return json[s];
  return json[camel] ?? json[s];
}

String _camelToSnake(String camel) {
  final buf = StringBuffer();
  for (var i = 0; i < camel.length; i++) {
    final c = camel[i];
    final lower = c.toLowerCase();
    if (c != lower && i > 0) buf.write('_');
    buf.write(lower);
  }
  return buf.toString();
}

int? jsonInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? jsonDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
