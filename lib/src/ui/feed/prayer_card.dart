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
    required this.onOpenDetail,
    required this.onReact,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final FeedPost item;
  final VoidCallback onOpenDetail;
  final ValueChanged<FeedReactionKind> onReact;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(formatFeedAuthorLabel(item), style: FeedStyles.authorLabel),
              if (item.isUrgent) ...<Widget>[
                const SizedBox(width: 10),
                UrgentBadge(),
              ],
              const Spacer(),
              Text(
                formatFeedPublishedTimeAgo(item.publishedAt),
                style: FeedStyles.publishedLabel,
              ),
              if (!item.viewerCanEdit || item.isFavorited) ...<Widget>[
                const SizedBox(width: 8),
                PrayerCardFavoriteButton(
                  isFavorited: item.isFavorited,
                  onTap: onToggleFavorite,
                ),
              ],
              const SizedBox(width: 8),
              PrayerCardMenuButton(
                isOwnPost: item.viewerCanEdit,
                onEdit: onEdit,
                onDelete: onDelete,
                onReport: onReport,
              ),
            ],
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Semantics(
              button: true,
              label: "Open prayer details",
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

class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: EditorialColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: EditorialColors.error.withValues(alpha: 0.24),
        ),
      ),
      child: const Text(
        "URGENT",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: EditorialColors.error,
        ),
      ),
    );
  }
}

class PrayerCardFavoriteButton extends StatelessWidget {
  const PrayerCardFavoriteButton({
    super.key,
    required this.isFavorited,
    required this.onTap,
  });

  final bool isFavorited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isFavorited
        ? EditorialColors.onSurface
        : EditorialColors.outline;

    return Tooltip(
      message: isFavorited ? "Remove from saved prayers" : "Save prayer",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isFavorited
                  ? EditorialColors.surfaceContainer
                  : EditorialColors.surfaceLow,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Icon(
              isFavorited ? Icons.bookmark : Icons.bookmark_border,
              size: 16,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class PrayerCardMenuButton extends StatelessWidget {
  const PrayerCardMenuButton({
    super.key,
    required this.isOwnPost,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final bool isOwnPost;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  static Color _softenMenuTextColor(Color color) {
    return color.withValues(alpha: 0.86);
  }

  static WidgetStateProperty<TextStyle?> _menuLabelTextStyle(Color color) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final bool isHovered =
          states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed);

      return TextStyle(
        fontSize: 13,
        fontWeight: isHovered ? FontWeight.w600 : FontWeight.w400,
        color: color,
      );
    });
  }

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

        if (value == "delete") {
          onDelete();
        }

        if (value == "report") {
          onReport();
        }
      },
      itemBuilder: (BuildContext context) => isOwnPost
          ? <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "edit",
                height: 40,
                padding: const EdgeInsets.all(10),
                labelTextStyle: _menuLabelTextStyle(
                  _softenMenuTextColor(EditorialColors.onSurface),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: EditorialColors.onSurface,
                    ),
                    SizedBox(width: 10),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "delete",
                height: 40,
                padding: const EdgeInsets.all(10),
                labelTextStyle: _menuLabelTextStyle(
                  _softenMenuTextColor(EditorialColors.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: EditorialColors.primary,
                    ),
                    SizedBox(width: 10),
                    Text("Delete"),
                  ],
                ),
              ),
            ]
          : <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "report",
                height: 40,
                padding: const EdgeInsets.all(10),
                labelTextStyle: _menuLabelTextStyle(
                  _softenMenuTextColor(EditorialColors.error),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: EditorialColors.error,
                    ),
                    SizedBox(width: 10),
                    Text("Report"),
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
