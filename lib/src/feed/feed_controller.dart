import "package:flutter/foundation.dart";

import "feed_api_client.dart";
import "feed_error_message.dart";
import "feed_models.dart";
import "feed_reaction.dart";
import "feed_state.dart";

class FeedController extends ChangeNotifier {
  static const int _pageSize = 10;

  FeedController({
    required FeedApiClient feedApiClient,
    required String accessToken,
  }) : _feedApiClient = feedApiClient,
       _accessToken = accessToken;

  final FeedApiClient _feedApiClient;
  final String _accessToken;

  FeedState _state = const FeedState.initial();
  bool _didBootstrap = false;
  bool _isDisposed = false;

  FeedState get state => _state;

  Future<void> bootstrap() async {
    if (_didBootstrap) {
      return;
    }

    // The screen can rebuild multiple times during startup. Bootstrap ensures
    // the first feed request is only kicked off once per controller instance.
    _didBootstrap = true;
    await refreshFeed();
  }

  Future<void> refreshFeed() async {
    if (_state.isLoading) {
      return;
    }

    _updateState(
      _state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        clearError: true,
        clearNextCursor: true,
      ),
    );

    try {
      final FeedPage page = await _feedApiClient.fetchFeed(
        _accessToken,
        limit: _pageSize,
      );
      _updateState(
        _state.copyWith(
          items: page.items,
          isLoading: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: mapFeedErrorMessage(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_state.isLoading || _state.isLoadingMore || !_state.hasMore) {
      return;
    }

    final String? cursor = _state.nextCursor;
    if (cursor == null || cursor.isEmpty) {
      _updateState(_state.copyWith(hasMore: false));
      return;
    }

    _updateState(_state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final FeedPage page = await _feedApiClient.fetchFeed(
        _accessToken,
        limit: _pageSize,
        cursor: cursor,
      );

      // Cursor-based pagination can briefly return overlapping items while the
      // list is changing server-side, so we de-duplicate by id before append.
      final Set<String> existingIds = _state.items
          .map((FeedPost item) => item.id)
          .toSet();
      final List<FeedPost> mergedItems = <FeedPost>[
        ..._state.items,
        ...page.items.where((FeedPost item) => !existingIds.contains(item.id)),
      ];

      _updateState(
        _state.copyWith(
          items: mergedItems,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(
          isLoadingMore: false,
          errorMessage: mapFeedErrorMessage(error),
        ),
      );
    }
  }

  Future<void> reactToPost(String postId, FeedReactionKind reaction) async {
    try {
      final FeedPostReactionResult result = await _feedApiClient.reactToPost(
        _accessToken,
        postId: postId,
        reaction: reaction,
      );

      final int postIndex = _state.items.indexWhere(
        (FeedPost item) => item.id == result.postId,
      );
      if (postIndex == -1) {
        return;
      }

      // Replacing only the changed post keeps the update work bounded even
      // when the visible feed grows large.
      final List<FeedPost> nextItems = List<FeedPost>.of(_state.items);
      nextItems[postIndex] = nextItems[postIndex].copyWith(
        reactionCount: result.reactionCount,
        reactionSummary: result.reactionSummary,
        viewerReaction: result.viewerReaction,
        clearViewerReaction: result.viewerReaction == null,
      );

      _updateState(_state.copyWith(items: nextItems, clearError: true));
    } catch (error) {
      _updateState(_state.copyWith(errorMessage: mapFeedErrorMessage(error)));
    }
  }

  Future<FeedCreatePostResult> createPost({
    required String body,
    required FeedVisibility visibility,
    required bool saveAsDraft,
  }) {
    return _feedApiClient.createPost(
      _accessToken,
      body: body,
      visibility: visibility,
      saveAsDraft: saveAsDraft,
    );
  }

  Future<FeedDraft?> fetchLatestDraft() {
    return _feedApiClient.fetchLatestDraft(_accessToken);
  }

  Future<FeedUpdatePostResult> updatePost({
    required String postId,
    required String body,
    required FeedVisibility visibility,
    bool publish = false,
  }) {
    return _feedApiClient.updatePost(
      _accessToken,
      postId: postId,
      body: body,
      visibility: visibility,
      publish: publish,
    );
  }

  Future<void> discardDraft(String postId) {
    return _feedApiClient.discardDraft(_accessToken, postId: postId);
  }

  Future<void> deletePost(String postId) async {
    await _feedApiClient.deletePost(_accessToken, postId: postId);

    final List<FeedPost> nextItems = _state.items
        .where((FeedPost item) => item.id != postId)
        .toList(growable: false);
    _updateState(_state.copyWith(items: nextItems, clearError: true));
  }

  void _updateState(FeedState nextState) {
    if (_isDisposed) {
      return;
    }

    _state = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
