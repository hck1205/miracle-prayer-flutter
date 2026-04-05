import "package:flutter/material.dart";

import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../design/editorial_tokens.dart";
import "expandable_prayer_body.dart";
import "feed_display.dart";
import "feed_reaction_widgets.dart";
import "feed_styles.dart";

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.item,
    required this.onReact,
    required this.onEdit,
  });

  final FeedPost item;
  final ValueChanged<FeedReactionKind> onReact;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(formatFeedAuthorLabel(item), style: FeedStyles.authorLabel),
              const Spacer(),
              Text(
                formatFeedPublishedTimeAgo(item.publishedAt),
                style: FeedStyles.publishedLabel,
              ),
              if (item.viewerCanEdit) ...<Widget>[
                const SizedBox(width: 8),
                _PrayerCardMenuButton(onEdit: onEdit),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
                decoration: FeedStyles.prayerBodyDecoration(),
                child: ExpandablePrayerBody(
                  body: item.body,
                  style: FeedStyles.prayerBody(),
                ),
              ),
              if (item.reactionSummary.hasAny)
                Positioned(
                  right: 4,
                  bottom: -12,
                  child: ReactionCountRow(summary: item.reactionSummary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          PrayerReactionButton(
            selectedReaction: item.viewerReaction,
            summary: item.reactionSummary,
            onSelected: onReact,
          ),
        ],
      ),
    );
  }
}

class _PrayerCardMenuButton extends StatelessWidget {
  const _PrayerCardMenuButton({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Open post menu",
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: EditorialColors.surfaceLowest,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x142D3435),
      elevation: 10,
      menuPadding: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: EditorialColors.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      onSelected: (String value) {
        if (value == "edit") {
          onEdit();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: "edit",
          height: 40,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const <Widget>[
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: EditorialColors.onSurface,
              ),
              SizedBox(width: 10),
              Text(
                "Edit",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EditorialColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
      padding: EdgeInsets.zero,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: EditorialColors.surfaceLow,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.more_horiz,
          size: 16,
          color: EditorialColors.outline,
        ),
      ),
    );
  }
}
