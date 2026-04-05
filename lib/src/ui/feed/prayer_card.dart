import "package:flutter/material.dart";

import "../../feed/feed_display.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "expandable_prayer_body.dart";
import "feed_reaction_widgets.dart";
import "feed_styles.dart";

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.item,
    required this.onReact,
  });

  final FeedPost item;
  final ValueChanged<FeedReactionKind> onReact;

  @override
  Widget build(BuildContext context) {
    final bool lined = item.isAiAuthored;

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
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
                decoration: FeedStyles.prayerBodyDecoration(lined: lined),
                child: ExpandablePrayerBody(
                  body: item.body,
                  style: FeedStyles.prayerBody(lined: lined),
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
