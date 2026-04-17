import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../localization/app_strings.dart";

Future<bool> showFeedDeleteConfirmDialog(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppStrings strings = context.strings;

      return AlertDialog(
        backgroundColor: EditorialColors.surfaceLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          strings.deleteDialogTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        content: Text(
          strings.deleteDialogBody,
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
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: EditorialColors.primary,
              foregroundColor: EditorialColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(strings.delete),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
