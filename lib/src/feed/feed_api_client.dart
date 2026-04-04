import "package:http/http.dart" as http;

import "../core/network/json_api_client.dart";
import "feed_models.dart";
import "feed_reaction.dart";

class FeedApiClient {
  FeedApiClient({required this.baseUrl, http.Client? httpClient})
    : _jsonApiClient = JsonApiClient(
        baseUrl: baseUrl,
        httpClient: httpClient,
      );

  final String baseUrl;
  final JsonApiClient _jsonApiClient;

  Future<List<FeedPost>> fetchFeed(
    String accessToken, {
    int limit = 30,
  }) async {
    final Map<String, dynamic> json = await _jsonApiClient.getJson(
      "/v1/feed?limit=$limit",
      headers: _jsonApiClient.bearerHeaders(accessToken),
    );

    final List<dynamic> items = json["items"] as List<dynamic>? ?? <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(FeedPost.fromJson)
        .toList(growable: false);
  }

  Future<FeedPostReactionResult> reactToPost(
    String accessToken, {
    required String postId,
    required FeedReactionKind reaction,
  }) async {
    final Map<String, dynamic> json = await _jsonApiClient.postJson(
      "/v1/feed/$postId/reactions",
      headers: _jsonApiClient.bearerHeaders(accessToken),
      body: <String, dynamic>{
        "type": _reactionTypeValue(reaction),
      },
    );

    return FeedPostReactionResult.fromJson(json);
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
