import "dart:convert";

enum FeedVisibility { public, anonymous }

enum FeedAuthorType { human, ai }

class FeedPost {
  const FeedPost({
    required this.id,
    required this.body,
    required this.visibility,
    required this.authorLabel,
    required this.authorType,
    required this.reactionCount,
    required this.commentCount,
    required this.publishedAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json["id"] as String,
      body: _decodeBody(json),
      visibility: _parseVisibility(json["visibility"] as String?),
      authorLabel: json["authorLabel"] as String? ?? "UNKNOWN",
      authorType: _parseAuthorType(json["authorType"] as String?),
      reactionCount: json["reactionCount"] as int? ?? 0,
      commentCount: json["commentCount"] as int? ?? 0,
      publishedAt: DateTime.parse(json["publishedAt"] as String),
    );
  }

  final String id;
  final String body;
  final FeedVisibility visibility;
  final String authorLabel;
  final FeedAuthorType authorType;
  final int reactionCount;
  final int commentCount;
  final DateTime publishedAt;

  bool get isAnonymous => visibility == FeedVisibility.anonymous;
  bool get isAiAuthored => authorType == FeedAuthorType.ai;

  static FeedVisibility _parseVisibility(String? value) {
    return switch (value) {
      "ANONYMOUS" => FeedVisibility.anonymous,
      _ => FeedVisibility.public,
    };
  }

  static FeedAuthorType _parseAuthorType(String? value) {
    return switch (value) {
      "AI" => FeedAuthorType.ai,
      _ => FeedAuthorType.human,
    };
  }

  static String _decodeBody(Map<String, dynamic> json) {
    final List<dynamic>? bodyCodePoints = json["bodyCodePoints"] as List<dynamic>?;

    if (bodyCodePoints != null && bodyCodePoints.isNotEmpty) {
      try {
        return String.fromCharCodes(
          bodyCodePoints.whereType<num>().map((value) => value.toInt()),
        );
      } catch (_) {
        // Fall back to the encoded string variants below.
      }
    }

    final String? bodyBase64 = json["bodyBase64"] as String?;

    if (bodyBase64 != null && bodyBase64.isNotEmpty) {
      try {
        return utf8.decode(base64Decode(bodyBase64));
      } catch (_) {
        // Fall back to the plain JSON body if decoding fails.
      }
    }

    return json["body"] as String? ?? "";
  }
}
