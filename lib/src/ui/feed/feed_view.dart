import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../feed/feed_state.dart";
import "../../localization/app_strings.dart";
import "feed_body_preview.dart";
import "feed_display.dart";
import "feed_styles.dart";
import "feed_widgets.dart";

class FeedView extends StatelessWidget {
  const FeedView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onLoadMore,
    required this.onOpenDetail,
    required this.onReact,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.headerTitle,
    required this.headerBody,
    required this.loadingMessage,
    required this.emptyTitle,
    required this.emptyBody,
    this.isReactionEnabledForPost,
    this.urgentState,
    this.onRetryUrgent,
  });

  final FeedState state;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<FeedPost> onOpenDetail;
  final void Function(FeedPost post, FeedReactionKind reaction) onReact;
  final ValueChanged<FeedPost> onToggleFavorite;
  final ValueChanged<FeedPost> onEdit;
  final ValueChanged<FeedPost> onDelete;
  final ValueChanged<FeedPost> onReport;
  final String headerTitle;
  final String headerBody;
  final String loadingMessage;
  final String emptyTitle;
  final String emptyBody;
  final bool Function(FeedPost post)? isReactionEnabledForPost;
  final FeedState? urgentState;
  final VoidCallback? onRetryUrgent;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final FeedState? urgentState = this.urgentState;
    final bool showUrgentSection =
        urgentState != null &&
        (urgentState.isLoading ||
            urgentState.errorMessage != null ||
            urgentState.items.isNotEmpty);

    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: scrollController,
              cacheExtent: 1200,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: EditorialCenteredViewport(
                    maxWidth: 620,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: FeedHeader(title: headerTitle, body: headerBody),
                    ),
                  ),
                ),
                if (showUrgentSection)
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: _UrgentPrayerSection(
                          state: urgentState,
                          onOpenDetail: onOpenDetail,
                          onRetry: onRetryUrgent,
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                if (state.isLoading && !state.hasItems)
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: _FeedLoadingState(message: loadingMessage),
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
                  SliverToBoxAdapter(
                    child: EditorialCenteredViewport(
                      maxWidth: 620,
                      child: _FeedEmptyState(
                        title: emptyTitle,
                        body: emptyBody,
                      ),
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
                        final bool isReactionEnabled =
                            isReactionEnabledForPost?.call(post) ?? true;

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
                                  onOpenDetail: () => onOpenDetail(post),
                                  onReact: (FeedReactionKind reaction) =>
                                      onReact(post, reaction),
                                  isReactionEnabled: isReactionEnabled,
                                  onToggleFavorite: () =>
                                      onToggleFavorite(post),
                                  onEdit: () => onEdit(post),
                                  onDelete: () => onDelete(post),
                                  onReport: () => onReport(post),
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
                              child: Text(strings.loadMore),
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

class _UrgentPrayerSection extends StatelessWidget {
  const _UrgentPrayerSection({
    required this.state,
    required this.onOpenDetail,
    required this.onRetry,
  });

  final FeedState? state;
  final ValueChanged<FeedPost> onOpenDetail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    final FeedState? state = this.state;
    if (state == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.urgentSectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: EditorialColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.urgentSectionBody,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 18),
        if (state.isLoading && state.items.isEmpty)
          const _UrgentPrayerLoading()
        else if (state.errorMessage != null && state.items.isEmpty)
          _UrgentPrayerError(message: state.errorMessage!, onRetry: onRetry)
        else
          _UrgentPrayerCarousel(
            items: state.items,
            onOpenDetail: onOpenDetail,
          ),
      ],
    );
  }
}

class _UrgentPrayerCarousel extends StatefulWidget {
  const _UrgentPrayerCarousel({
    required this.items,
    required this.onOpenDetail,
  });

  final List<FeedPost> items;
  final ValueChanged<FeedPost> onOpenDetail;

  @override
  State<_UrgentPrayerCarousel> createState() => _UrgentPrayerCarouselState();
}

class _UrgentPrayerCarouselState extends State<_UrgentPrayerCarousel> {
  late final PageController _pageController;
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _pageController.addListener(_handlePageChanged);
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 206,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: <PointerDeviceKind>{
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
                PointerDeviceKind.invertedStylus,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              padEnds: false,
              itemBuilder: (BuildContext context, int index) {
                final FeedPost post = widget.items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.items.length - 1 ? 0 : 14,
                  ),
                  child: _UrgentPrayerCard(
                    post: post,
                    onTap: () => widget.onOpenDetail(post),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.items.length > 1) ...<Widget>[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(widget.items.length, (int index) {
              final bool isActive = (_page.round()).clamp(
                    0,
                    widget.items.length - 1,
                  ) ==
                  index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: isActive ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? EditorialColors.onSurface
                      : EditorialColors.outlineVariant.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _handlePageChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _page = _pageController.page ?? _pageController.initialPage.toDouble();
    });
  }
}

class _UrgentPrayerCard extends StatelessWidget {
  const _UrgentPrayerCard({required this.post, required this.onTap});

  final FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
        child: Ink(
          decoration: BoxDecoration(
            color: EditorialColors.surfaceLowest,
            borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
            border: Border.all(
              color: EditorialColors.outlineVariant.withValues(alpha: 0.18),
            ),
            boxShadow: EditorialShadows.ambient,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Text(
                      formatFeedPublishedTimeAgo(context, post.publishedAt),
                      style: FeedStyles.publishedLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 82,
                  child: Text(
                    normalizeFeedPreviewBody(post.body),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: FeedStyles.prayerBody().copyWith(
                      fontSize: 16,
                      height: 1.68,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Text(
                      formatFeedAuthorLabel(context, post),
                      style: FeedStyles.authorLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentPrayerLoading extends StatelessWidget {
  const _UrgentPrayerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: EditorialColors.surfaceLowest,
        borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
        border: Border.all(
          color: EditorialColors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: const Center(child: EditorialInlineLoader(width: 92, height: 2)),
    );
  }
}

class _UrgentPrayerError extends StatelessWidget {
  const _UrgentPrayerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EditorialColors.surfaceLowest,
        borderRadius: BorderRadius.circular(EditorialRadius.xLarge),
        border: Border.all(
          color: EditorialColors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          EditorialStatusMessage(
            message: message,
            color: EditorialColors.primary,
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 14),
            EditorialSecondaryButton(label: strings.tryAgain, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          const EditorialInlineLoader(width: 120, height: 2),
          const SizedBox(height: 18),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: EditorialColors.outline,
            ),
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
    final AppStrings strings = context.strings;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: <Widget>[
          EditorialStatusMessage(
            message: message,
            color: EditorialColors.primary,
          ),
          const SizedBox(height: 18),
          EditorialSecondaryButton(label: strings.tryAgain, onPressed: onRetry),
        ],
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: EditorialColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
