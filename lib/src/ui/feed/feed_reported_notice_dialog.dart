import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";

Future<void> showFeedReportedNoticeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: EditorialColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Already reported",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        content: const Text(
          "You already reported this prayer. Thank you for letting us know.",
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: EditorialColors.primary,
              foregroundColor: EditorialColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
