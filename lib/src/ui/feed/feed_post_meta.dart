import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../feed/feed_models.dart";
import "../../localization/app_strings.dart";
import "feed_display.dart";
import "feed_styles.dart";

class FeedPostMetaRow extends StatelessWidget {
  const FeedPostMetaRow({
    super.key,
    required this.post,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    this.isFavoriteEnabled = true,
    this.isMenuEnabled = true,
  });

  final FeedPost post;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final bool isFavoriteEnabled;
  final bool isMenuEnabled;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    // Keep card and detail metadata in one widget so action/layout updates stay
    // consistent everywhere a post is shown.
    return Row(
      children: <Widget>[
        Text(formatFeedAuthorLabel(context, post), style: FeedStyles.authorLabel),
        if (post.isUrgent) ...<Widget>[
          const SizedBox(width: 10),
          UrgentBadge(label: strings.urgentBadge),
        ],
        const Spacer(),
        Text(
          formatFeedPublishedTimeAgo(context, post.publishedAt),
          style: FeedStyles.publishedLabel,
        ),
        if (!post.viewerCanEdit || post.isFavorited) ...<Widget>[
          const SizedBox(width: 8),
          IgnorePointer(
            ignoring: !isFavoriteEnabled,
            child: PrayerCardFavoriteButton(
              isFavorited: post.isFavorited,
              onTap: onToggleFavorite,
            ),
          ),
        ],
        const SizedBox(width: 8),
        IgnorePointer(
          ignoring: !isMenuEnabled,
          child: PrayerCardMenuButton(
            isOwnPost: post.viewerCanEdit,
            onEdit: onEdit,
            onDelete: onDelete,
            onReport: onReport,
          ),
        ),
      ],
    );
  }
}

class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key, required this.label});

  final String label;

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
      child: Text(
        label,
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
    final AppStrings strings = context.strings;
    final Color iconColor = isFavorited
        ? EditorialColors.onSurface
        : EditorialColors.outline;

    return Tooltip(
      message: isFavorited
          ? strings.favoriteTooltipRemove
          : strings.favoriteTooltipSave,
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
    final AppStrings strings = context.strings;
    return PopupMenuButton<String>(
      tooltip: strings.postMenuTooltip,
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
                  children: <Widget>[
                    const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: EditorialColors.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Text(strings.postMenuEdit),
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
                  children: <Widget>[
                    const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: EditorialColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(strings.postMenuDelete),
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
                  children: <Widget>[
                    const Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: EditorialColors.error,
                    ),
                    const SizedBox(width: 10),
                    Text(strings.postMenuReport),
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
