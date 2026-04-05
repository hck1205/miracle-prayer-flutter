import "package:http/http.dart" as http;

import "../core/network/json_api_client.dart";
import "feed_models.dart";
import "feed_report.dart";
import "feed_reaction.dart";

class FeedApiClient {
  FeedApiClient({required this.baseUrl, http.Client? httpClient})
    : _jsonApiClient = JsonApiClient(baseUrl: baseUrl, httpClient: httpClient);

  final String baseUrl;
  final JsonApiClient _jsonApiClient;

  Future<FeedPage> fetchFeed(
    String accessToken, {
    int limit = 10,
    String? cursor,
  }) async {
    final StringBuffer path = StringBuffer("/v1/feed?limit=$limit");
    if (cursor != null && cursor.isNotEmpty) {
      path.write("&cursor=${Uri.encodeQueryComponent(cursor)}");
    }

    final Map<String, dynamic> json = await _jsonApiClient.getJson(
      path.toString(),
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );

    final List<dynamic> items = json["items"] as List<dynamic>? ?? <dynamic>[];

    return FeedPage(
      items: items
          .whereType<Map<String, dynamic>>()
          .map(FeedPost.fromJson)
          .toList(growable: false),
      nextCursor: json["nextCursor"] as String?,
      hasMore: json["hasMore"] as bool? ?? false,
    );
  }

  Future<FeedPostReactionResult> reactToPost(
    String accessToken, {
    required String postId,
    required FeedReactionKind reaction,
  }) async {
    final Map<String, dynamic> json = await _jsonApiClient.postJson(
      "/v1/feed/$postId/reactions",
      headers: _jsonApiClient.bearerHeaders(accessToken),
      body: <String, dynamic>{"type": _reactionTypeValue(reaction)},
    );

    return FeedPostReactionResult.fromJson(json);
  }

  Future<FeedCreatePostResult> createPost(
    String accessToken, {
    required String body,
    required FeedVisibility visibility,
    required bool saveAsDraft,
  }) async {
    final Map<String, dynamic> json = await _jsonApiClient.postJson(
      "/v1/feed",
      headers: _jsonApiClient.bearerHeaders(accessToken),
      body: <String, dynamic>{
        "body": body,
        "visibility": switch (visibility) {
          FeedVisibility.anonymous => "ANONYMOUS",
          FeedVisibility.public => "PUBLIC",
        },
        "status": saveAsDraft ? "DRAFT" : "PUBLISHED",
      },
    );

    return FeedCreatePostResult.fromJson(json);
  }

  Future<FeedDraft?> fetchLatestDraft(String accessToken) async {
    final Map<String, dynamic> json = await _jsonApiClient.getJson(
      "/v1/feed/drafts/latest",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );

    final Map<String, dynamic>? draftJson =
        json["draft"] as Map<String, dynamic>?;
    if (draftJson == null) {
      return null;
    }

    return FeedDraft.fromJson(draftJson);
  }

  Future<FeedUpdatePostResult> updatePost(
    String accessToken, {
    required String postId,
    required String body,
    required FeedVisibility visibility,
    bool publish = false,
  }) async {
    final Map<String, dynamic> requestBody = <String, dynamic>{
      "body": body,
      "visibility": switch (visibility) {
        FeedVisibility.anonymous => "ANONYMOUS",
        FeedVisibility.public => "PUBLIC",
      },
      if (publish) "status": "PUBLISHED",
    };

    final Map<String, dynamic> json = await _jsonApiClient.postJson(
      "/v1/feed/$postId",
      headers: _jsonApiClient.bearerHeaders(accessToken),
      body: requestBody,
    );

    return FeedUpdatePostResult.fromJson(json);
  }

  Future<void> discardDraft(String accessToken, {required String postId}) {
    return _jsonApiClient.postEmpty(
      "/v1/feed/$postId/discard",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );
  }

  Future<void> deletePost(String accessToken, {required String postId}) {
    return _jsonApiClient.deleteEmpty(
      "/v1/feed/$postId",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );
  }

  Future<void> reportPost(
    String accessToken, {
    required String postId,
    required FeedReportSubmission submission,
  }) {
    return _jsonApiClient.postEmpty(
      "/v1/feed/$postId/report",
      headers: _jsonApiClient.bearerHeaders(accessToken),
      body: <String, dynamic>{
        "reason": submission.reason.apiValue,
        if (submission.details != null && submission.details!.trim().isNotEmpty)
          "details": submission.details!.trim(),
      },
    );
  }

  String _reactionTypeValue(FeedReactionKind reaction) {
    return switch (reaction) {
      FeedReactionKind.love => "LOVE",
      FeedReactionKind.amen => "AMEN",
      FeedReactionKind.withYou => "WITH_YOU",
      FeedReactionKind.peace => "PEACE",
    };
  }
}

class FeedCreatePostResult {
  const FeedCreatePostResult({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.publishedAt,
  });

  factory FeedCreatePostResult.fromJson(Map<String, dynamic> json) {
    return FeedCreatePostResult(
      id: json["id"] as String,
      status: json["status"] as String? ?? "PUBLISHED",
      createdAt: DateTime.parse(json["createdAt"] as String),
      publishedAt: json["publishedAt"] == null
          ? null
          : DateTime.parse(json["publishedAt"] as String),
    );
  }

  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? publishedAt;

  bool get isDraft => status == "DRAFT";
}

class FeedPostReactionResult {
  const FeedPostReactionResult({
    required this.postId,
    required this.reactionCount,
    required this.reactionSummary,
    required this.viewerReaction,
  });

  factory FeedPostReactionResult.fromJson(Map<String, dynamic> json) {
    return FeedPostReactionResult(
      postId: json["postId"] as String,
      reactionCount: json["reactionCount"] as int? ?? 0,
      reactionSummary: FeedReactionSummary.fromJson(
        json["reactionSummary"] as Map<String, dynamic>?,
      ),
      viewerReaction: _parseViewerReaction(json["viewerReaction"] as String?),
    );
  }

  final String postId;
  final int reactionCount;
  final FeedReactionSummary reactionSummary;
  final FeedReactionKind? viewerReaction;

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

class FeedUpdatePostResult {
  const FeedUpdatePostResult({
    required this.id,
    required this.body,
    required this.visibility,
    required this.status,
    required this.updatedAt,
    required this.publishedAt,
  });

  factory FeedUpdatePostResult.fromJson(Map<String, dynamic> json) {
    return FeedUpdatePostResult(
      id: json["id"] as String,
      body: json["body"] as String? ?? "",
      visibility: switch (json["visibility"] as String?) {
        "ANONYMOUS" => FeedVisibility.anonymous,
        _ => FeedVisibility.public,
      },
      status: json["status"] as String? ?? "PUBLISHED",
      updatedAt: DateTime.parse(json["updatedAt"] as String),
      publishedAt: json["publishedAt"] == null
          ? null
          : DateTime.parse(json["publishedAt"] as String),
    );
  }

  final String id;
  final String body;
  final FeedVisibility visibility;
  final String status;
  final DateTime updatedAt;
  final DateTime? publishedAt;
}
