import "package:http/http.dart" as http;

import "../core/network/json_api_client.dart";
import "feed_models.dart";

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
}
