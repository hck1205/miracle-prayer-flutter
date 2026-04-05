import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../feed/feed_report.dart";

Future<FeedReportSubmission?> showFeedReportDialog(BuildContext context) {
  FeedReportReason? selectedReason;
  final TextEditingController detailsController = TextEditingController();

  return showDialog<FeedReportSubmission>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final bool requiresDetails = selectedReason == FeedReportReason.other;
          final bool canSubmit =
              selectedReason != null &&
              (!requiresDetails || detailsController.text.trim().isNotEmpty);

          return AlertDialog(
            backgroundColor: EditorialColors.surfaceLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Report this prayer",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: EditorialColors.onSurface,
              ),
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Choose the reason that best fits this post.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: EditorialColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final FeedReportReason reason in FeedReportReason.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => selectedReason = reason),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selectedReason == reason
                                ? EditorialColors.surfaceLow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedReason == reason
                                  ? EditorialColors.primary
                                  : EditorialColors.outlineVariant.withValues(
                                      alpha: 0.45,
                                    ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedReason == reason
                                        ? EditorialColors.primary
                                        : EditorialColors.outlineVariant,
                                    width: 1.5,
                                  ),
                                ),
                                child: selectedReason == reason
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: EditorialColors.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      reason.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: EditorialColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reason.description,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: EditorialColors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (requiresDetails) ...<Widget>[
                    const SizedBox(height: 6),
                    TextField(
                      controller: detailsController,
                      maxLength: 500,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Please tell us what happened.",
                        filled: true,
                        fillColor: EditorialColors.surfaceLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: EditorialColors.outlineVariant.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: EditorialColors.outlineVariant.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide(
                            color: EditorialColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: EditorialColors.onSurfaceMuted,
                  side: const BorderSide(color: EditorialColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: !canSubmit
                    ? null
                    : () => Navigator.of(context).pop(
                        FeedReportSubmission(
                          reason: selectedReason!,
                          details: detailsController.text.trim(),
                        ),
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: EditorialColors.primary,
                  foregroundColor: EditorialColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                child: const Text("Submit report"),
              ),
            ],
          );
        },
      );
    },
  );
}
