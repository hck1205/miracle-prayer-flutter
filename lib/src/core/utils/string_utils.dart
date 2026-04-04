String? normalizeNullable(String? value) {
  if (value == null) {
    return null;
  }

  final String normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String leadingCharacter(String value, {String fallback = "?"}) {
  final String normalized = value.trim();

  if (normalized.isEmpty) {
    return fallback;
  }

  return normalized.substring(0, 1).toUpperCase();
}
