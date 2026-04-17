import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../localization/app_strings.dart";
import "feed_styles.dart";

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
  static const Offset _reactionTrayOffset = Offset(-6, -65);

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
    final AppStrings strings = context.strings;
    final bool isAmenSelected =
        widget.selectedReaction == FeedReactionKind.amen;
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
                    child: ReactionGlyph(
                      option: primaryOption,
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    primaryOption.label(strings),
                    style: FeedStyles.reactionLabel(primaryColor),
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

    // The tray lives in the root overlay so hover animations and positioning
    // stay decoupled from the feed list item's rebuild cycle.
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
                offset: _reactionTrayOffset,
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

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      _overlayEntry = null;
      return;
    }

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
      _ReactionCountBadgeData(
        option: FeedReactions.peace,
        count: summary.peace,
      ),
    ].where((entry) => entry.count > 0).toList(growable: false);

    return _ReactionCountSummary(entries: entries, totalCount: summary.total);
  }
}

class ReactionGlyph extends StatelessWidget {
  const ReactionGlyph({
    super.key,
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
      style: TextStyle(fontSize: size, height: 1, color: color),
    );
  }
}

class _ReactionTray extends StatelessWidget {
  static const EdgeInsets _trayPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 8,
  );
  static const EdgeInsets _itemSpacing = EdgeInsets.symmetric(horizontal: 3);

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
        padding: _trayPadding,
        decoration: FeedStyles.reactionTrayDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: FeedReactions.all
              .map(
                (FeedReactionOption option) => Padding(
                  padding: _itemSpacing,
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
  static const EdgeInsets _defaultItemPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 5,
  );
  static const EdgeInsets _activeItemPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 7,
  );

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
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
          transform: Matrix4.translationValues(0.0, elevated ? -4.0 : 0.0, 0.0),
          padding: elevated ? _activeItemPadding : _defaultItemPadding,
          decoration: BoxDecoration(
            color: elevated ? EditorialColors.surfaceLow : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ReactionGlyph(
                option: widget.option,
                size: 16,
                color: EditorialColors.onSurface,
              ),
              const SizedBox(height: 4),
              Text(widget.option.label(strings), style: FeedStyles.trayLabel),
              if (widget.count > 0) ...<Widget>[
                const SizedBox(height: 2),
                Text("${widget.count}", style: FeedStyles.trayCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionCountBadgeData {
  const _ReactionCountBadgeData({required this.option, required this.count});

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
    final List<_ReactionCountBadgeData> visibleEntries = entries
        .take(4)
        .toList(growable: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < visibleEntries.length; index++) ...<Widget>[
          _ReactionListGlyph(data: visibleEntries[index]),
          if (index < visibleEntries.length - 1) const SizedBox(width: 4),
        ],
        const SizedBox(width: 8),
        Text("$totalCount", style: FeedStyles.reactionSummaryLabel),
      ],
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
        child: ReactionGlyph(
          option: data.option,
          size: 12,
          color: EditorialColors.onSurfaceMuted,
        ),
      ),
    );
  }
}
