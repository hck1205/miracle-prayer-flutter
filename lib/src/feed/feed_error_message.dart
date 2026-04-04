import "../core/network/api_exception.dart";

String mapFeedErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }

  return "Unable to load the prayer feed right now.";
}
