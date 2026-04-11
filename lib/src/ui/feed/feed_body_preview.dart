String normalizeFeedPreviewBody(String body) {
  return body
      .split(RegExp(r"\r?\n+"))
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .join(" ")
      .replaceAll(RegExp(r"\s{2,}"), " ")
      .trim();
}
