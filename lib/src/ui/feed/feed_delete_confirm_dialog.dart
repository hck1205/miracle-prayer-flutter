import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";

Future<bool> showFeedDeleteConfirmDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: EditorialColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete this prayer?",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        content: const Text(
          "This prayer will be removed from the feed. This action cannot be undone.",
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: EditorialColors.onSurfaceMuted,
              side: const BorderSide(color: EditorialColors.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: EditorialColors.primary,
              foregroundColor: EditorialColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
