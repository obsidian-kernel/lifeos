import 'dart:convert';

List<String> parseStringList(String? jsonArray) {
  if (jsonArray == null || jsonArray.isEmpty) return const [];
  try {
    final decoded = json.decode(jsonArray);
    if (decoded is List) {
      return decoded.whereType<String>().toList();
    }
  } catch (_) {
    // swallow
  }
  return const [];
}

String toJsonString(List<String> items) => json.encode(items);
