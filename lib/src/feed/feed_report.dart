enum FeedReportReason {
  notPrayer,
  abusiveOrHarassing,
  promotionalOrOffTopic,
  other,
}

class FeedReportSubmission {
  const FeedReportSubmission({required this.reason, this.details});

  final FeedReportReason reason;
  final String? details;
}

extension FeedReportReasonValues on FeedReportReason {
  String get apiValue {
    return switch (this) {
      FeedReportReason.notPrayer => "NOT_A_PRAYER",
      FeedReportReason.abusiveOrHarassing => "ABUSIVE_OR_HARASSING",
      FeedReportReason.promotionalOrOffTopic => "PROMOTIONAL_OR_OFF_TOPIC",
      FeedReportReason.other => "OTHER",
    };
  }

  String get title {
    return switch (this) {
      FeedReportReason.notPrayer => "Not a prayer",
      FeedReportReason.abusiveOrHarassing => "Abusive or hateful",
      FeedReportReason.promotionalOrOffTopic => "Promotional or unrelated",
      FeedReportReason.other => "Other",
    };
  }

  String get description {
    return switch (this) {
      FeedReportReason.notPrayer =>
        "Posts that are not actually prayer requests or prayer content.",
      FeedReportReason.abusiveOrHarassing =>
        "Profanity, personal attacks, defamation, harassment, or hateful content.",
      FeedReportReason.promotionalOrOffTopic =>
        "Advertisements, spam, or posts that do not fit the purpose of this app.",
      FeedReportReason.other =>
        "Anything else that should be reviewed. Please provide details.",
    };
  }
}
