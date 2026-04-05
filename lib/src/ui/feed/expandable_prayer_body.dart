import "package:flutter/material.dart";

import "feed_styles.dart";

class ExpandablePrayerBody extends StatefulWidget {
  const ExpandablePrayerBody({
    super.key,
    required this.body,
    required this.style,
  });

  final String body;
  final TextStyle style;

  @override
  State<ExpandablePrayerBody> createState() => _ExpandablePrayerBodyState();
}

class _ExpandablePrayerBodyState extends State<ExpandablePrayerBody> {
  static const int _collapsedMaxLines = 8;
  static const String _expandLabel = "더 보기";

  bool _isExpanded = false;
  bool _isExpandHovered = false;
  double? _cachedMaxWidth;
  bool? _cachedHasOverflow;

  @override
  void didUpdateWidget(covariant ExpandablePrayerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body || oldWidget.style != widget.style) {
      _cachedMaxWidth = null;
      _cachedHasOverflow = null;
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool hasOverflow = _resolveHasOverflow(
          maxWidth: constraints.maxWidth,
          textDirection: Directionality.of(context),
        );

        if (_isExpanded || !hasOverflow) {
          return Text(widget.body, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.body,
              maxLines: _collapsedMaxLines,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isExpandHovered = true),
                onExit: (_) => setState(() => _isExpandHovered = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _isExpanded = true),
                  child: Text(
                    _expandLabel,
                    style: FeedStyles.expandAction(hovered: _isExpandHovered),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _resolveHasOverflow({
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    if (_cachedMaxWidth == maxWidth && _cachedHasOverflow != null) {
      return _cachedHasOverflow!;
    }

    final TextPainter painter = TextPainter(
      text: TextSpan(text: widget.body, style: widget.style),
      maxLines: _collapsedMaxLines,
      textDirection: textDirection,
    )..layout(maxWidth: maxWidth);

    _cachedMaxWidth = maxWidth;
    _cachedHasOverflow = painter.didExceedMaxLines;
    return _cachedHasOverflow!;
  }
}
