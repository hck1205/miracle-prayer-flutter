import "../../feed/feed_models.dart";

String formatFeedAuthorLabel(FeedPost post) {
  final String feedNumber = post.postNumber > 0 ? "#${post.postNumber}" : "#--";
  return "$feedNumber ANONYMOUS";
}

String formatFeedPublishedTimeAgo(DateTime publishedAt, {DateTime? now}) {
  final Duration difference = (now ?? DateTime.now()).difference(publishedAt);
  final DateTime localPublishedAt = publishedAt.toLocal();

  if (difference.inMinutes < 1) {
    return "방금 전";
  }

  if (difference.inHours < 1) {
    return "${difference.inMinutes}분 전";
  }

  if (difference.inDays < 1) {
    return "${difference.inHours}시간 전";
  }

  if (difference.inDays == 1) {
    return "어제";
  }

  return "${localPublishedAt.month}월 ${localPublishedAt.day}일";
}
