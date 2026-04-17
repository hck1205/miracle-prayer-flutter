import "package:flutter/widgets.dart";

import "../../feed/feed_models.dart";
import "../../localization/app_strings.dart";

String formatFeedAuthorLabel(BuildContext context, FeedPost post) {
  final AppStrings strings = context.strings;
  final String feedNumber = post.postNumber > 0 ? "#${post.postNumber}" : "#--";
  return strings.feedAuthorAnonymous(feedNumber);
}

String formatFeedPublishedTimeAgo(
  BuildContext context,
  DateTime publishedAt, {
  DateTime? now,
}) {
  final AppStrings strings = context.strings;
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
    return strings.feedTimeJustNow;
  }

  if (difference.inHours < 1) {
    final int minutes = difference.inMinutes;
    return strings.feedTimeMinute(minutes);
  }

  if (difference.inDays < 1) {
    final int hours = difference.inHours;
    return strings.feedTimeHour(hours);
  }

  if (difference.inDays == 1) {
    return strings.feedTimeYesterday;
  }

  return strings.formatMonthDay(localPublishedAt);
}
