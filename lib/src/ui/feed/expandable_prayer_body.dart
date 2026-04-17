import "package:flutter/material.dart";

import "../../localization/app_strings.dart";
import "feed_body_preview.dart";
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

  bool _isExpanded = false;
  bool _isExpandHovered = false;
  double? _cachedMaxWidth;
  bool? _cachedHasOverflow;
  TextScaler? _cachedTextScaler;

  @override
  void didUpdateWidget(covariant ExpandablePrayerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body || oldWidget.style != widget.style) {
      _cachedMaxWidth = null;
      _cachedHasOverflow = null;
      _cachedTextScaler = null;
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final String collapsedPreview = normalizeFeedPreviewBody(widget.body);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool hasOverflow = _resolveHasOverflow(
          body: collapsedPreview,
          maxWidth: constraints.maxWidth,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        );

        if (_isExpanded || !hasOverflow) {
          return Text(
            _isExpanded ? widget.body : collapsedPreview,
            style: widget.style,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              collapsedPreview,
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
                    strings.feedReadMore,
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
    required String body,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    // Measuring text is relatively expensive, so we reuse the last result until
    // the layout width or text scaling changes.
    if (_cachedMaxWidth == maxWidth &&
        _cachedTextScaler == textScaler &&
        _cachedHasOverflow != null) {
      return _cachedHasOverflow!;
    }

    final TextPainter painter = TextPainter(
      text: TextSpan(text: body, style: widget.style),
      maxLines: _collapsedMaxLines,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);

    _cachedMaxWidth = maxWidth;
    _cachedHasOverflow = painter.didExceedMaxLines;
    _cachedTextScaler = textScaler;
    return _cachedHasOverflow!;
  }
}
