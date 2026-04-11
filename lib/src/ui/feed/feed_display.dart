import "../../feed/feed_models.dart";

String formatFeedAuthorLabel(FeedPost post) {
  final String feedNumber = post.postNumber > 0 ? "#${post.postNumber}" : "#--";
  return "$feedNumber ANONYMOUS";
}

String formatFeedPublishedTimeAgo(DateTime publishedAt, {DateTime? now}) {
  // Future timestamps can briefly appear while test data or device clocks are
  // being adjusted, so the label clamps negative durations to zero.
  final Duration rawDifference = (now ?? DateTime.now()).difference(
    publishedAt,
  );
  final Duration difference = rawDifference.isNegative
      ? Duration.zero
      : rawDifference;
  final DateTime localPublishedAt = publishedAt.toLocal();

  if (difference.inMinutes < 1) {
    return "Just now";
  }

  if (difference.inHours < 1) {
    final int minutes = difference.inMinutes;
    return minutes == 1 ? "1 min ago" : "$minutes min ago";
  }

  if (difference.inDays < 1) {
    final int hours = difference.inHours;
    return hours == 1 ? "1 hr ago" : "$hours hrs ago";
  }

  if (difference.inDays == 1) {
    return "Yesterday";
  }

  return "${localPublishedAt.month}/${localPublishedAt.day}";
}
