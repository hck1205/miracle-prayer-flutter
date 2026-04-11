import "feed_reaction.dart";

enum FeedVisibility { public, anonymous }

enum FeedAuthorType { human, ai }

enum FeedPostType { urgent }

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
  static const Duration editWindow = Duration(hours: 1);

  const FeedPost({
    required this.id,
    required this.postNumber,
    required this.body,
    required this.visibility,
    required this.type,
    required this.viewerCanEdit,
    required this.viewerHasFavorited,
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
      postNumber: json["postNumber"] as int? ?? 0,
      body: json["body"] as String? ?? "",
      visibility: _parseVisibility(json["visibility"] as String?),
      type: _parseType(json["type"] as String?),
      viewerCanEdit: json["viewerCanEdit"] as bool? ?? false,
      viewerHasFavorited: json["viewerHasFavorited"] as bool? ?? false,
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
  final int postNumber;
  final String body;
  final FeedVisibility visibility;
  final FeedPostType? type;
  final bool viewerCanEdit;
  final bool viewerHasFavorited;
  final String authorLabel;
  final FeedAuthorType authorType;
  final int reactionCount;
  final FeedReactionSummary reactionSummary;
  final FeedReactionKind? viewerReaction;
  final int commentCount;
  final DateTime publishedAt;

  bool get isAnonymous => visibility == FeedVisibility.anonymous;
  bool get isUrgent => type == FeedPostType.urgent;
  bool get hasReaction => viewerReaction != null;
  bool get isFavorited => viewerHasFavorited;
  bool get isWithinEditWindow =>
      DateTime.now().isBefore(publishedAt.add(editWindow));

  FeedPost copyWith({
    String? id,
    int? postNumber,
    String? body,
    FeedVisibility? visibility,
    FeedPostType? type,
    bool clearType = false,
    bool? viewerCanEdit,
    bool? viewerHasFavorited,
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
      postNumber: postNumber ?? this.postNumber,
      body: body ?? this.body,
      visibility: visibility ?? this.visibility,
      type: clearType ? null : (type ?? this.type),
      viewerCanEdit: viewerCanEdit ?? this.viewerCanEdit,
      viewerHasFavorited: viewerHasFavorited ?? this.viewerHasFavorited,
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

  static FeedPostType? _parseType(String? value) {
    return switch (value) {
      "URGENT" => FeedPostType.urgent,
      _ => null,
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
    required this.type,
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
      type: switch (json["type"] as String?) {
        "URGENT" => FeedPostType.urgent,
        _ => null,
      },
      updatedAt: DateTime.parse(json["updatedAt"] as String),
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }

  final String id;
  final String body;
  final FeedVisibility visibility;
  final FeedPostType? type;
  final DateTime updatedAt;
  final DateTime createdAt;

  bool get isAnonymous => visibility == FeedVisibility.anonymous;
  bool get isUrgent => type == FeedPostType.urgent;
}

class FeedUrgentEligibility {
  const FeedUrgentEligibility({
    required this.canUseUrgent,
    required this.cooldownSeconds,
    required this.nextAvailableAt,
  });

  factory FeedUrgentEligibility.fromJson(Map<String, dynamic> json) {
    return FeedUrgentEligibility(
      canUseUrgent: json["canUseUrgent"] as bool? ?? false,
      cooldownSeconds: json["cooldownSeconds"] as int? ?? 0,
      nextAvailableAt: json["nextAvailableAt"] == null
          ? null
          : DateTime.parse(json["nextAvailableAt"] as String),
    );
  }

  final bool canUseUrgent;
  final int cooldownSeconds;
  final DateTime? nextAvailableAt;
}
