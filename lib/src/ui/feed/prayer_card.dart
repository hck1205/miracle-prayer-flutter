import "package:flutter/material.dart";

import "expandable_prayer_body.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../localization/app_strings.dart";
import "feed_post_meta.dart";
import "feed_reaction_widgets.dart";
import "feed_styles.dart";

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.item,
    required this.onOpenDetail,
    required this.onReact,
    this.isReactionEnabled = true,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final FeedPost item;
  final VoidCallback onOpenDetail;
  final ValueChanged<FeedReactionKind> onReact;
  final bool isReactionEnabled;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FeedPostMetaRow(
            post: item,
            onToggleFavorite: onToggleFavorite,
            onEdit: onEdit,
            onDelete: onDelete,
            onReport: onReport,
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Semantics(
              button: true,
              label: strings.openPrayerDetails,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenDetail,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
                  decoration: FeedStyles.prayerBodyDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ExpandablePrayerBody(
                        body: item.body,
                        style: FeedStyles.prayerBody(),
                      ),
                      if (item.reactionSummary.hasAny) ...<Widget>[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ReactionCountRow(
                            summary: item.reactionSummary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: isReactionEnabled ? 1 : 0.55,
            child: IgnorePointer(
              ignoring: !isReactionEnabled,
              child: PrayerReactionButton(
                selectedReaction: item.viewerReaction,
                summary: item.reactionSummary,
                onSelected: onReact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
