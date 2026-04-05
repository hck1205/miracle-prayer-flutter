import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../feed/feed_state.dart";
import "feed_widgets.dart";

class FeedView extends StatelessWidget {
  const FeedView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onLoadMore,
    required this.onReact,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedState state;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final void Function(FeedPost post, FeedReactionKind reaction) onReact;
  final ValueChanged<FeedPost> onEdit;
  final ValueChanged<FeedPost> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: scrollController,
              cacheExtent: 1200,
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: EditorialCenteredViewport(
                    maxWidth: 620,
                    child: Padding(
                      padding: EdgeInsets.only(top: 28),
                      child: FeedHeader(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                if (state.isLoading && !state.hasItems)
                  const SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: _FeedLoadingState(),
                    ),
                  )
                else if (state.errorMessage != null && !state.hasItems)
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: _FeedErrorState(
                        message: state.errorMessage!,
                        onRetry: onRetry,
                      ),
                    ),
                  )
                else if (!state.hasItems)
                  const SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: _FeedEmptyState(),
                    ),
                  )
                else ...<Widget>[
                  if (state.isLoading)
                    const SliverToBoxAdapter(
                      child: EditorialCenteredViewport(
                        maxWidth: 620,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: EditorialInlineLoader(width: 96, height: 2),
                          ),
                        ),
                      ),
                    ),
                  if (state.errorMessage != null)
                    SliverToBoxAdapter(
                      child: EditorialCenteredViewport(
                        maxWidth: 620,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: EditorialStatusMessage(
                            message: state.errorMessage!,
                            color: EditorialColors.primary,
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final FeedPost post = state.items[index];
                        final bool isLast = index == state.items.length - 1;

                        return EditorialCenteredViewport(
                          maxWidth: 620,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                PrayerCard(
                                  key: ValueKey<String>(post.id),
                                  item: post,
                                  onReact: (FeedReactionKind reaction) =>
                                      onReact(post, reaction),
                                  onEdit: () => onEdit(post),
                                  onDelete: () => onDelete(post),
                                ),
                                if (!isLast)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 28),
                                    child: Center(child: EditorialDivider()),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.items.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                    ),
                  ),
                ],
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(
                          child: EditorialInlineLoader(width: 84, height: 2),
                        ),
                      ),
                    ),
                  )
                else if (state.hasItems && state.hasMore)
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: onLoadMore,
                            child: const Text("Load more"),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(
                  child: EditorialCenteredViewport(
                    maxWidth: 620,
                    child: FeedFooter(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          EditorialInlineLoader(width: 120, height: 2),
          SizedBox(height: 18),
          Text(
            "Loading prayers...",
            style: TextStyle(fontSize: 14, color: EditorialColors.outline),
          ),
        ],
      ),
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  const _FeedErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: <Widget>[
          EditorialStatusMessage(
            message: message,
            color: EditorialColors.primary,
          ),
          const SizedBox(height: 18),
          EditorialSecondaryButton(label: "Try again", onPressed: onRetry),
        ],
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Text(
            "No prayers yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: EditorialColors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "The feed will appear here once stories begin to gather.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
