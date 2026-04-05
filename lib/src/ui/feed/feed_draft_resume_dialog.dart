import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";

enum FeedDraftResumeAction { continueWriting, startNew }

Future<FeedDraftResumeAction?> showFeedDraftResumeDialog(BuildContext context) {
  return showDialog<FeedDraftResumeAction>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: EditorialColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Saved draft found",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        content: const Text(
          "You already have a prayer draft. Would you like to continue writing it or start a new one?",
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(FeedDraftResumeAction.startNew),
            style: OutlinedButton.styleFrom(
              foregroundColor: EditorialColors.onSurfaceMuted,
              side: const BorderSide(color: EditorialColors.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("Start New"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(FeedDraftResumeAction.continueWriting),
            style: FilledButton.styleFrom(
              backgroundColor: EditorialColors.primary,
              foregroundColor: EditorialColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("Continue Writing"),
          ),
        ],
      );
    },
  );
}
