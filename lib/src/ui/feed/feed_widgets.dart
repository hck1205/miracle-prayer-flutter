import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_typography.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_display.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";

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
    required this.onReact,
  });

  final FeedPost item;
  final ValueChanged<FeedReactionKind> onReact;

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
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
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
            if (item.reactionSummary.hasAny)
              Positioned(
                right: 4,
                bottom: -12,
                child: ReactionCountRow(summary: item.reactionSummary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PrayerReactionButton(
              selectedReaction: item.viewerReaction,
              summary: item.reactionSummary,
              onSelected: onReact,
            ),
          ],
        ),
      ],
    );
  }
}

class PrayerReactionButton extends StatefulWidget {
  const PrayerReactionButton({
    super.key,
    required this.selectedReaction,
    required this.summary,
    required this.onSelected,
  });

  final FeedReactionKind? selectedReaction;
  final FeedReactionSummary summary;
  final ValueChanged<FeedReactionKind> onSelected;

  @override
  State<PrayerReactionButton> createState() => _PrayerReactionButtonState();
}

class _PrayerReactionButtonState extends State<PrayerReactionButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const FeedReactionOption primaryOption = FeedReactions.amen;
    final bool isAmenSelected = widget.selectedReaction == FeedReactionKind.amen;
    final Color primaryColor = isAmenSelected
        ? EditorialColors.primary
        : EditorialColors.outline;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            onTap: () => _selectReaction(FeedReactionKind.amen),
            onLongPress: _showReactionTray,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedScale(
                    scale: _isHovered ? 1.08 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: _ReactionGlyph(
                      option: primaryOption,
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    primaryOption.label,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                      fontFamily: EditorialTypography.displayFontFamily,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectReaction(FeedReactionKind reaction) {
    widget.onSelected(reaction);
    _removeOverlay();
  }

  void _showReactionTray() {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned.fill(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(-6, -78),
                child: _ReactionTray(
                  selectedReaction: widget.selectedReaction,
                  summary: widget.summary,
                  onSelected: _selectReaction,
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ReactionTray extends StatelessWidget {
  const _ReactionTray({
    required this.selectedReaction,
    required this.summary,
    required this.onSelected,
  });

  final FeedReactionKind? selectedReaction;
  final FeedReactionSummary summary;
  final ValueChanged<FeedReactionKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: EditorialColors.surfaceLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: EditorialColors.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x122D3435),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: FeedReactions.all
              .map(
                (FeedReactionOption option) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ReactionTrayItem(
                    option: option,
                    isSelected: option.kind == selectedReaction,
                    count: summary.countFor(option.kind),
                    onTap: () => onSelected(option.kind),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _ReactionTrayItem extends StatefulWidget {
  const _ReactionTrayItem({
    required this.option,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  final FeedReactionOption option;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  @override
  State<_ReactionTrayItem> createState() => _ReactionTrayItemState();
}

class _ReactionTrayItemState extends State<_ReactionTrayItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool elevated = _isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, elevated ? -6.0 : 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: elevated
                ? EditorialColors.surfaceLow
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ReactionGlyph(
                option: widget.option,
                size: 22,
                color: EditorialColors.onSurface,
              ),
              const SizedBox(height: 6),
              Text(
                widget.option.label,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w700,
                  fontFamily: EditorialTypography.displayFontFamily,
                  color: EditorialColors.outline,
                ),
              ),
              if (widget.count > 0) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  "${widget.count}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: EditorialTypography.displayFontFamily,
                    color: EditorialColors.onSurfaceMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ReactionCountRow extends StatelessWidget {
  const ReactionCountRow({super.key, required this.summary});

  final FeedReactionSummary summary;

  @override
  Widget build(BuildContext context) {
    final List<_ReactionCountBadgeData> entries = <_ReactionCountBadgeData>[
      _ReactionCountBadgeData(option: FeedReactions.amen, count: summary.amen),
      _ReactionCountBadgeData(option: FeedReactions.love, count: summary.love),
      _ReactionCountBadgeData(
        option: FeedReactions.withYou,
        count: summary.withYou,
      ),
      _ReactionCountBadgeData(option: FeedReactions.peace, count: summary.peace),
    ].where((entry) => entry.count > 0).toList(growable: false);

    return Align(
      alignment: Alignment.centerLeft,
      child: _ReactionCountSummary(
        entries: entries,
        totalCount: summary.total,
      ),
    );
  }
}

class _ReactionCountBadgeData {
  const _ReactionCountBadgeData({
    required this.option,
    required this.count,
  });

  final FeedReactionOption option;
  final int count;
}

class _ReactionCountSummary extends StatelessWidget {
  const _ReactionCountSummary({
    required this.entries,
    required this.totalCount,
  });

  final List<_ReactionCountBadgeData> entries;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final List<_ReactionCountBadgeData> visibleEntries = entries.take(4).toList(
      growable: false,
    );

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EditorialColors.surfaceLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: EditorialColors.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x082D3435),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < visibleEntries.length; index++) ...<Widget>[
            _ReactionListGlyph(data: visibleEntries[index]),
            if (index < visibleEntries.length - 1) const SizedBox(width: 6),
          ],
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: EditorialColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "$totalCount",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: EditorialTypography.displayFontFamily,
                color: EditorialColors.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionListGlyph extends StatelessWidget {
  const _ReactionListGlyph({required this.data});

  final _ReactionCountBadgeData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: _ReactionGlyph(
          option: data.option,
          size: 13,
          color: EditorialColors.outline,
        ),
      ),
    );
  }
}

class _ReactionGlyph extends StatelessWidget {
  const _ReactionGlyph({
    required this.option,
    required this.size,
    required this.color,
  });

  final FeedReactionOption option;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (option.icon case final IconData icon) {
      return Icon(icon, size: size, color: color);
    }

    return Text(
      option.emoji ?? "",
      style: TextStyle(
        fontSize: size,
        height: 1,
        color: color,
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
