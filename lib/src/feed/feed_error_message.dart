import "../core/network/api_exception.dart";

const String feedUnavailableCode = "feed.unavailable";

String mapFeedErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }

  return feedUnavailableCode;
}
