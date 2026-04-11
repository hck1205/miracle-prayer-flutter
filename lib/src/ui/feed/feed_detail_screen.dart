import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_controller.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "feed_display.dart";
import "feed_reaction_widgets.dart";
import "feed_styles.dart";
import "prayer_card.dart";

class FeedDetailScreen extends StatefulWidget {
  const FeedDetailScreen({
    super.key,
    required this.controller,
    required this.initialPost,
    required this.onReact,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final FeedController controller;
  final FeedPost initialPost;
  final Future<void> Function(String postId, FeedReactionKind reaction) onReact;
  final Future<bool> Function(String postId) onToggleFavorite;
  final Future<void> Function(FeedPost post) onEdit;
  final Future<bool> Function(FeedPost post) onDelete;
  final Future<void> Function(FeedPost post) onReport;

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  late FeedPost _currentPost;
  bool _isProcessingFavorite = false;
  bool _isProcessingReaction = false;
  bool _isProcessingDelete = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.initialPost;
    widget.controller.addListener(_syncFromController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeedPost post = _currentPost;

    return Scaffold(
      backgroundColor: EditorialColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            EditorialCenteredViewport(
              maxWidth: 620,
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: EditorialColors.onSurface,
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Prayer detail",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: EditorialColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
                child: EditorialCenteredViewport(
                    maxWidth: 620,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const EditorialDivider(),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Text(
                            formatFeedAuthorLabel(post),
                            style: FeedStyles.authorLabel,
                          ),
                          if (post.isUrgent) ...<Widget>[
                            const SizedBox(width: 10),
                            UrgentBadge(),
                          ],
                          const Spacer(),
                          Text(
                            formatFeedPublishedTimeAgo(post.publishedAt),
                            style: FeedStyles.publishedLabel,
                          ),
                          if (!post.viewerCanEdit || post.isFavorited) ...<Widget>[
                            const SizedBox(width: 8),
                            IgnorePointer(
                              ignoring: _isProcessingFavorite,
                              child: PrayerCardFavoriteButton(
                                isFavorited: post.isFavorited,
                                onTap: _handleToggleFavorite,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          IgnorePointer(
                            ignoring: _isProcessingDelete,
                            child: PrayerCardMenuButton(
                              isOwnPost: post.viewerCanEdit,
                              onEdit: _handleEdit,
                              onDelete: _handleDelete,
                              onReport: _handleReport,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          EditorialRadius.xLarge,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: EditorialColors.surfaceLowest,
                            borderRadius: BorderRadius.circular(
                              EditorialRadius.xLarge,
                            ),
                            border: Border.all(
                              color: EditorialColors.outlineVariant.withValues(
                                alpha: 0.18,
                              ),
                            ),
                            boxShadow: EditorialShadows.ambient,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  28,
                                  30,
                                  28,
                                  28,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SelectableText(
                                      post.body,
                                      style: FeedStyles.prayerBody().copyWith(
                                        fontSize: 20,
                                        height: 1.92,
                                        color: EditorialColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (post.reactionSummary.hasAny)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    28,
                                    18,
                                    28,
                                    18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: EditorialColors.surfaceLow,
                                    border: Border(
                                      top: BorderSide(
                                        color: EditorialColors.outlineVariant
                                            .withValues(alpha: 0.16),
                                      ),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ReactionCountRow(
                                      summary: post.reactionSummary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: _isProcessingReaction ? 0.55 : 1,
                        child: IgnorePointer(
                          ignoring: _isProcessingReaction,
                          child: PrayerReactionButton(
                            selectedReaction: post.viewerReaction,
                            summary: post.reactionSummary,
                            onSelected: _handleReactionSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFromController() {
    final FeedPost? nextPost = _findPostById(_currentPost.id);
    if (nextPost == null || !mounted) {
      return;
    }

    setState(() {
      _currentPost = nextPost;
    });
  }

  FeedPost? _findPostById(String postId) {
    for (final FeedPost item in widget.controller.state.items) {
      if (item.id == postId) {
        return item;
      }
    }

    for (final FeedPost item in widget.controller.favoritesState.items) {
      if (item.id == postId) {
        return item;
      }
    }

    return null;
  }

  Future<void> _handleReactionSelected(FeedReactionKind reaction) async {
    setState(() {
      _isProcessingReaction = true;
    });

    try {
      await widget.onReact(_currentPost.id, reaction);
      _syncFromController();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingReaction = false;
        });
      }
    }
  }

  Future<void> _handleToggleFavorite() async {
    setState(() {
      _isProcessingFavorite = true;
    });

    try {
      final bool isFavorited = await widget.onToggleFavorite(_currentPost.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPost = _currentPost.copyWith(
          viewerHasFavorited: isFavorited,
        );
      });
      _syncFromController();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingFavorite = false;
        });
      }
    }
  }

  Future<void> _handleEdit() async {
    await widget.onEdit(_currentPost);

    if (!mounted) {
      return;
    }

    Navigator.of(context).maybePop();
  }

  Future<void> _handleDelete() async {
    setState(() {
      _isProcessingDelete = true;
    });

    try {
      final bool didDelete = await widget.onDelete(_currentPost);
      if (!mounted || !didDelete) {
        return;
      }

      Navigator.of(context).maybePop();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingDelete = false;
        });
      }
    }
  }

  Future<void> _handleReport() {
    return widget.onReport(_currentPost);
  }
}
