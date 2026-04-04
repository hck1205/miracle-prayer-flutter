import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_typography.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_display.dart";
import "../../feed/feed_models.dart";

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "A collective breath.",
          style: TextStyle(
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: EditorialColors.onSurface,
          ),
        ),
        SizedBox(height: 16),
        EditorialDivider(),
        SizedBox(height: 24),
        Text(
          "Join a silent community of voices.\nShare your burdens, find solace in the\nshared spirit of hope.",
          style: TextStyle(
            fontSize: 17,
            height: 1.75,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.item,
    required this.onLove,
    required this.onAmen,
    required this.onWithYou,
  });

  final FeedPost item;
  final VoidCallback onLove;
  final VoidCallback onAmen;
  final VoidCallback onWithYou;

  @override
  Widget build(BuildContext context) {
    final bool lined = item.isAiAuthored;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              formatFeedAuthorLabel(item),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                fontFamily: EditorialTypography.displayFontFamily,
                fontFamilyFallback: EditorialTypography.sansFallback,
                color: EditorialColors.onSurfaceMuted,
              ),
            ),
            const Spacer(),
            Text(
              formatFeedPublishedTimeAgo(item.publishedAt),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.3,
                fontFamily: EditorialTypography.displayFontFamily,
                fontFamilyFallback: EditorialTypography.sansFallback,
                color: EditorialColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: lined
                ? EditorialColors.surfaceLowest
                : EditorialColors.surfaceLow,
            border: lined
                ? const Border(
                    left: BorderSide(
                      color: EditorialColors.outlineVariant,
                      width: 2,
                    ),
                  )
                : null,
            borderRadius: lined ? null : BorderRadius.circular(12),
          ),
          child: Text(
            item.body,
            style: EditorialTypography.withKoreanContent(
              TextStyle(
              fontSize: 19,
              height: 1.8,
              fontWeight: FontWeight.w300,
              fontStyle: lined ? FontStyle.normal : FontStyle.italic,
              color: EditorialColors.onSurface,
            ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            PrayerAction(
              icon: Icons.favorite_border,
              hoverIcon: Icons.favorite,
              label: "LOVE",
              onTap: onLove,
            ),
            const SizedBox(width: 22),
            PrayerAction(
              icon: Icons.front_hand_outlined,
              hoverIcon: Icons.front_hand,
              label: "AMEN",
              onTap: onAmen,
            ),
            const SizedBox(width: 22),
            PrayerAction(
              icon: Icons.volunteer_activism_outlined,
              hoverIcon: Icons.volunteer_activism,
              label: "WITH YOU",
              iconSize: 18,
              onTap: onWithYou,
            ),
          ],
        ),
      ],
    );
  }
}

class PrayerAction extends StatefulWidget {
  const PrayerAction({
    super.key,
    required this.icon,
    required this.hoverIcon,
    required this.label,
    required this.onTap,
    this.iconSize = 16,
  });

  final IconData icon;
  final IconData hoverIcon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;

  @override
  State<PrayerAction> createState() => _PrayerActionState();
}

class _PrayerActionState extends State<PrayerAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: Icon(
                    _isHovered ? widget.hoverIcon : widget.icon,
                    size: widget.iconSize,
                    color: EditorialColors.outline,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    fontFamily: EditorialTypography.displayFontFamily,
                    color: EditorialColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeedFooter extends StatelessWidget {
  const FeedFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        EditorialDivider(),
        SizedBox(height: 16),
        Text(
          "PEACE BE WITH YOU",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.0,
            color: EditorialColors.outline,
          ),
        ),
      ],
    );
  }
}

class FeedBottomBar extends StatelessWidget {
  const FeedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: EditorialColors.surface.withValues(alpha: 0.94),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            BottomNavItem(
              icon: Icons.home_filled,
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            BottomNavItem(
              icon: Icons.add_circle_outline,
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            BottomNavItem(
              icon: Icons.favorite_border,
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? EditorialColors.surfaceContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 20,
            color: selected
                ? EditorialColors.onSurface
                : EditorialColors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
