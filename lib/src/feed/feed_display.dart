import "feed_models.dart";

String formatFeedAuthorLabel(FeedPost post) {
  return post.isAnonymous ? "ANONYMOUS" : post.authorLabel;
}

String formatFeedPublishedTimeAgo(DateTime publishedAt, {DateTime? now}) {
  final Duration difference = (now ?? DateTime.now()).difference(publishedAt);
  final DateTime localPublishedAt = publishedAt.toLocal();

  if (difference.inMinutes < 1) {
    return "\uBC29\uAE08 \uC804";
  }

  if (difference.inHours < 1) {
    return "${difference.inMinutes}\uBD84 \uC804";
  }

  if (difference.inDays < 1) {
    return "${difference.inHours}\uC2DC\uAC04 \uC804";
  }

  if (difference.inDays == 1) {
    return "\uC5B4\uC81C";
  }

  return "${localPublishedAt.month}\uC6D4 ${localPublishedAt.day}\uC77C";
}
