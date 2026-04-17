import "../localization/app_strings.dart";

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

  String title(AppStrings strings) {
    return switch (this) {
      FeedReportReason.notPrayer => strings.reportReasonNotPrayerTitle(),
      FeedReportReason.abusiveOrHarassing => strings.reportReasonAbusiveTitle(),
      FeedReportReason.promotionalOrOffTopic =>
        strings.reportReasonPromotionalTitle(),
      FeedReportReason.other => strings.reportReasonOtherTitle(),
    };
  }

  String description(AppStrings strings) {
    return switch (this) {
      FeedReportReason.notPrayer =>
        strings.reportReasonNotPrayerDescription(),
      FeedReportReason.abusiveOrHarassing =>
        strings.reportReasonAbusiveDescription(),
      FeedReportReason.promotionalOrOffTopic =>
        strings.reportReasonPromotionalDescription(),
      FeedReportReason.other => strings.reportReasonOtherDescription(),
    };
  }
}
