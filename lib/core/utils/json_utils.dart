/// Small helpers for tolerant JSON parsing.
///
/// The ASP.NET API serializes properties in camelCase but some anonymous
/// objects keep acronyms (e.g. `courseID`), so lookups are case-insensitive.
extension JsonMapX on Map<String, dynamic> {
  /// Returns the value for [key] ignoring case, or null.
  dynamic pick(String key) {
    if (containsKey(key)) return this[key];
    final lower = key.toLowerCase();
    for (final entry in entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  int asInt(String key, {int fallback = 0}) {
    final v = pick(key);
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? fallback;
  }

  int? asIntOrNull(String key) {
    final v = pick(key);
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  double asDouble(String key, {double fallback = 0}) {
    final v = pick(key);
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? fallback;
  }

  String asString(String key, {String fallback = ''}) => pick(key)?.toString() ?? fallback;

  String? asStringOrNull(String key) => pick(key)?.toString();

  bool asBool(String key, {bool fallback = false}) {
    final v = pick(key);
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true';
    return fallback;
  }

  DateTime? asDate(String key) => DateTime.tryParse(pick(key)?.toString() ?? '');

  List<Map<String, dynamic>> asList(String key) => asMapList(pick(key));
}

/// Converts a dynamic JSON value into a list of maps (empty when not a list).
List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}
