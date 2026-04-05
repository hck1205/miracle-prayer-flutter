import "feed_reaction.dart";

enum FeedVisibility { public, anonymous }

enum FeedAuthorType { human, ai }

class FeedReactionSummary {
  const FeedReactionSummary({
    required this.love,
    required this.amen,
    required this.withYou,
    required this.peace,
    required this.total,
  });

  const FeedReactionSummary.empty()
    : love = 0,
      amen = 0,
      withYou = 0,
      peace = 0,
      total = 0;

  factory FeedReactionSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeedReactionSummary.empty();
    }

    return FeedReactionSummary(
      love: json["LOVE"] as int? ?? 0,
      amen: json["AMEN"] as int? ?? 0,
      withYou: json["WITH_YOU"] as int? ?? 0,
      peace: json["PEACE"] as int? ?? 0,
      total: json["total"] as int? ?? 0,
    );
  }

  final int love;
  final int amen;
  final int withYou;
  final int peace;
  final int total;

  int countFor(FeedReactionKind kind) {
    return switch (kind) {
      FeedReactionKind.love => love,
      FeedReactionKind.amen => amen,
      FeedReactionKind.withYou => withYou,
      FeedReactionKind.peace => peace,
    };
  }

  bool get hasAny => total > 0;

  FeedReactionSummary copyWith({
    int? love,
    int? amen,
    int? withYou,
    int? peace,
    int? total,
  }) {
    return FeedReactionSummary(
      love: love ?? this.love,
      amen: amen ?? this.amen,
      withYou: withYou ?? this.withYou,
      peace: peace ?? this.peace,
      total: total ?? this.total,
    );
  }
}

class FeedPage {
  const FeedPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<FeedPost> items;
  final String? nextCursor;
  final bool hasMore;
}

class FeedPost {
  const FeedPost({
    required this.id,
    required this.body,
    required this.visibility,
    required this.viewerCanEdit,
    required this.authorLabel,
    required this.authorType,
    required this.reactionCount,
    required this.reactionSummary,
    required this.viewerReaction,
    required this.commentCount,
    required this.publishedAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json["id"] as String,
      body: json["body"] as String? ?? "",
      visibility: _parseVisibility(json["visibility"] as String?),
      viewerCanEdit: json["viewerCanEdit"] as bool? ?? false,
      authorLabel: json["authorLabel"] as String? ?? "UNKNOWN",
      authorType: _parseAuthorType(json["authorType"] as String?),
      reactionCount: json["reactionCount"] as int? ?? 0,
      reactionSummary: FeedReactionSummary.fromJson(
        json["reactionSummary"] as Map<String, dynamic>?,
      ),
      viewerReaction: _parseViewerReaction(json["viewerReaction"] as String?),
      commentCount: json["commentCount"] as int? ?? 0,
      publishedAt: DateTime.parse(json["publishedAt"] as String),
    );
  }

  final String id;
  final String body;
  final FeedVisibility visibility;
  final bool viewerCanEdit;
  final String authorLabel;
  final FeedAuthorType authorType;
  final int reactionCount;
  final FeedReactionSummary reactionSummary;
  final FeedReactionKind? viewerReaction;
  final int commentCount;
  final DateTime publishedAt;

  bool get isAnonymous => visibility == FeedVisibility.anonymous;
  bool get hasReaction => viewerReaction != null;

  FeedPost copyWith({
    String? id,
    String? body,
    FeedVisibility? visibility,
    bool? viewerCanEdit,
    String? authorLabel,
    FeedAuthorType? authorType,
    int? reactionCount,
    FeedReactionSummary? reactionSummary,
    FeedReactionKind? viewerReaction,
    bool clearViewerReaction = false,
    int? commentCount,
    DateTime? publishedAt,
  }) {
    return FeedPost(
      id: id ?? this.id,
      body: body ?? this.body,
      visibility: visibility ?? this.visibility,
      viewerCanEdit: viewerCanEdit ?? this.viewerCanEdit,
      authorLabel: authorLabel ?? this.authorLabel,
      authorType: authorType ?? this.authorType,
      reactionCount: reactionCount ?? this.reactionCount,
      reactionSummary: reactionSummary ?? this.reactionSummary,
      viewerReaction: clearViewerReaction
          ? null
          : (viewerReaction ?? this.viewerReaction),
      commentCount: commentCount ?? this.commentCount,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

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

  static FeedReactionKind? _parseViewerReaction(String? value) {
    return switch (value) {
      "LOVE" => FeedReactionKind.love,
      "AMEN" => FeedReactionKind.amen,
      "WITH_YOU" => FeedReactionKind.withYou,
      "PEACE" => FeedReactionKind.peace,
      _ => null,
    };
  }
}

class FeedDraft {
  const FeedDraft({
    required this.id,
    required this.body,
    required this.visibility,
    required this.updatedAt,
    required this.createdAt,
  });

  factory FeedDraft.fromJson(Map<String, dynamic> json) {
    return FeedDraft(
      id: json["id"] as String,
      body: json["body"] as String? ?? "",
      visibility: switch (json["visibility"] as String?) {
        "ANONYMOUS" => FeedVisibility.anonymous,
        _ => FeedVisibility.public,
      },
      updatedAt: DateTime.parse(json["updatedAt"] as String),
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }

  final String id;
  final String body;
  final FeedVisibility visibility;
  final DateTime updatedAt;
  final DateTime createdAt;

  bool get isAnonymous => visibility == FeedVisibility.anonymous;
}
