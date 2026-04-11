import "package:flutter/foundation.dart";

import "feed_api_client.dart";
import "feed_error_message.dart";
import "feed_models.dart";
import "feed_report.dart";
import "feed_reaction.dart";
import "feed_state.dart";

class FeedController extends ChangeNotifier {
  static const int _pageSize = 10;
  static const int _urgentPageSize = 5;

  FeedController({
    required FeedApiClient feedApiClient,
    required String accessToken,
  }) : _feedApiClient = feedApiClient,
       _accessToken = accessToken;

  final FeedApiClient _feedApiClient;
  final String _accessToken;

  FeedState _state = const FeedState.initial();
  FeedState _favoritesState = const FeedState.initial();
  FeedState _urgentState = const FeedState.initial();
  bool _didBootstrap = false;
  bool _didBootstrapFavorites = false;
  bool _isDisposed = false;

  FeedState get state => _state;
  FeedState get favoritesState => _favoritesState;
  FeedState get urgentState => _urgentState;

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

    _updateBothStates(
      feedState: _state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        clearError: true,
        clearNextCursor: true,
      ),
      urgentState: _urgentState.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasMore: false,
        clearError: true,
        clearNextCursor: true,
      ),
    );

    FeedPage? feedPage;
    String? feedErrorMessage;
    FeedPage? urgentPage;
    String? urgentErrorMessage;

    try {
      feedPage = await _feedApiClient.fetchFeed(
        _accessToken,
        limit: _pageSize,
      );
    } catch (error) {
      feedErrorMessage = mapFeedErrorMessage(error);
    }

    try {
      urgentPage = await _feedApiClient.fetchUrgentFeed(
        _accessToken,
        limit: _urgentPageSize,
      );
    } catch (error) {
      urgentErrorMessage = mapFeedErrorMessage(error);
    }

    _updateBothStates(
      feedState: feedPage == null
          ? _state.copyWith(isLoading: false, errorMessage: feedErrorMessage)
          : _state.copyWith(
              items: feedPage.items,
              isLoading: false,
              isLoadingMore: false,
              hasMore: feedPage.hasMore,
              nextCursor: feedPage.nextCursor,
              clearError: true,
            ),
      urgentState: urgentPage == null
          ? _urgentState.copyWith(
              isLoading: false,
              isLoadingMore: false,
              hasMore: false,
              errorMessage: urgentErrorMessage,
            )
          : _urgentState.copyWith(
              items: urgentPage.items,
              isLoading: false,
              isLoadingMore: false,
              hasMore: false,
              clearNextCursor: true,
              clearError: true,
            ),
    );
  }

  Future<void> bootstrapFavorites() async {
    if (_didBootstrapFavorites) {
      return;
    }

    _didBootstrapFavorites = true;
    await refreshFavorites();
  }

  Future<void> refreshFavorites() async {
    if (_favoritesState.isLoading) {
      return;
    }

    _updateFavoritesState(
      _favoritesState.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        clearError: true,
        clearNextCursor: true,
      ),
    );

    try {
      final FeedPage page = await _feedApiClient.fetchFavorites(
        _accessToken,
        limit: _pageSize,
      );
      _updateFavoritesState(
        _favoritesState.copyWith(
          items: page.items,
          isLoading: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
    } catch (error) {
      _updateFavoritesState(
        _favoritesState.copyWith(
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

  Future<void> loadMoreFavorites() async {
    if (_favoritesState.isLoading ||
        _favoritesState.isLoadingMore ||
        !_favoritesState.hasMore) {
      return;
    }

    final String? cursor = _favoritesState.nextCursor;
    if (cursor == null || cursor.isEmpty) {
      _updateFavoritesState(_favoritesState.copyWith(hasMore: false));
      return;
    }

    _updateFavoritesState(
      _favoritesState.copyWith(isLoadingMore: true, clearError: true),
    );

    try {
      final FeedPage page = await _feedApiClient.fetchFavorites(
        _accessToken,
        limit: _pageSize,
        cursor: cursor,
      );

      final List<FeedPost> mergedItems = _mergeItems(
        _favoritesState.items,
        page.items,
      );

      _updateFavoritesState(
        _favoritesState.copyWith(
          items: mergedItems,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
    } catch (error) {
      _updateFavoritesState(
        _favoritesState.copyWith(
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
        final int favoriteIndex = _favoritesState.items.indexWhere(
          (FeedPost item) => item.id == result.postId,
        );
        if (favoriteIndex == -1) {
          return;
        }
      }

      final FeedPost? basePost = _findPostById(result.postId);
      if (basePost == null) {
        return;
      }

      final FeedPost updatedPost = basePost.copyWith(
        reactionCount: result.reactionCount,
        reactionSummary: result.reactionSummary,
        viewerReaction: result.viewerReaction,
        clearViewerReaction: result.viewerReaction == null,
      );

      _updateBothStates(
        feedState: _replacePostInState(_state, updatedPost, clearError: true),
        favoritesState: _replacePostInState(
          _favoritesState,
          updatedPost,
          clearError: true,
        ),
        urgentState: _replacePostInState(
          _urgentState,
          updatedPost,
          clearError: true,
        ),
      );
    } catch (error) {
      _updateState(_state.copyWith(errorMessage: mapFeedErrorMessage(error)));
    }
  }

  Future<bool> toggleFavorite(String postId) async {
    final FeedPostFavoriteResult result = await _feedApiClient.toggleFavorite(
      _accessToken,
      postId: postId,
    );

    final FeedPost? basePost = _findPostById(postId);
    if (basePost == null) {
      return result.viewerHasFavorited;
    }

    final FeedPost updatedPost = basePost.copyWith(
      viewerHasFavorited: result.viewerHasFavorited,
    );

    final FeedState nextFeedState = _replacePostInState(
      _state,
      updatedPost,
      clearError: true,
    );
    final FeedState nextFavoritesState = result.viewerHasFavorited
        ? _upsertFavoritePost(updatedPost)
        : _removeFavoritePost(postId);

    _updateBothStates(
      feedState: nextFeedState,
      favoritesState: nextFavoritesState.copyWith(clearError: true),
      urgentState: _replacePostInState(
        _urgentState,
        updatedPost,
        clearError: true,
      ),
    );

    return result.viewerHasFavorited;
  }

  Future<FeedCreatePostResult> createPost({
    required String body,
    required FeedVisibility visibility,
    required FeedPostType? type,
    required bool saveAsDraft,
  }) {
    return _feedApiClient.createPost(
      _accessToken,
      body: body,
      visibility: visibility,
      type: type,
      saveAsDraft: saveAsDraft,
    );
  }

  Future<FeedDraft?> fetchLatestDraft() {
    return _feedApiClient.fetchLatestDraft(_accessToken);
  }

  Future<FeedUrgentEligibility> fetchUrgentEligibility({
    String? excludePostId,
  }) {
    return _feedApiClient.fetchUrgentEligibility(
      _accessToken,
      excludePostId: excludePostId,
    );
  }

  Future<FeedUpdatePostResult> updatePost({
    required String postId,
    required String body,
    required FeedVisibility visibility,
    required FeedPostType? type,
    bool publish = false,
  }) {
    return _feedApiClient.updatePost(
      _accessToken,
      postId: postId,
      body: body,
      visibility: visibility,
      type: type,
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
    final List<FeedPost> nextFavoriteItems = _favoritesState.items
        .where((FeedPost item) => item.id != postId)
        .toList(growable: false);
    final List<FeedPost> nextUrgentItems = _urgentState.items
        .where((FeedPost item) => item.id != postId)
        .toList(growable: false);
    _updateBothStates(
      feedState: _state.copyWith(items: nextItems, clearError: true),
      favoritesState: _favoritesState.copyWith(
        items: nextFavoriteItems,
        clearError: true,
      ),
      urgentState: _urgentState.copyWith(
        items: nextUrgentItems,
        clearError: true,
      ),
    );
  }

  Future<void> reportPost(String postId, FeedReportSubmission submission) {
    return _feedApiClient.reportPost(
      _accessToken,
      postId: postId,
      submission: submission,
    );
  }

  void _updateState(FeedState nextState) {
    _updateBothStates(feedState: nextState);
  }

  void _updateFavoritesState(FeedState nextState) {
    _updateBothStates(favoritesState: nextState);
  }

  void _updateBothStates({
    FeedState? feedState,
    FeedState? favoritesState,
    FeedState? urgentState,
  }) {
    if (_isDisposed) {
      return;
    }

    _state = feedState ?? _state;
    _favoritesState = favoritesState ?? _favoritesState;
    _urgentState = urgentState ?? _urgentState;
    notifyListeners();
  }

  List<FeedPost> _mergeItems(List<FeedPost> current, List<FeedPost> incoming) {
    final Set<String> existingIds = current
        .map((FeedPost item) => item.id)
        .toSet();
    return <FeedPost>[
      ...current,
      ...incoming.where((FeedPost item) => !existingIds.contains(item.id)),
    ];
  }

  FeedPost? _findPostById(String postId) {
    for (final FeedPost item in _state.items) {
      if (item.id == postId) {
        return item;
      }
    }

    for (final FeedPost item in _favoritesState.items) {
      if (item.id == postId) {
        return item;
      }
    }

    return null;
  }

  FeedState _replacePostInState(
    FeedState source,
    FeedPost updatedPost, {
    bool clearError = false,
  }) {
    final int index = source.items.indexWhere(
      (FeedPost item) => item.id == updatedPost.id,
    );
    if (index == -1) {
      return clearError ? source.copyWith(clearError: true) : source;
    }

    final List<FeedPost> nextItems = List<FeedPost>.of(source.items);
    nextItems[index] = updatedPost;
    return source.copyWith(items: nextItems, clearError: clearError);
  }

  FeedState _upsertFavoritePost(FeedPost updatedPost) {
    final int index = _favoritesState.items.indexWhere(
      (FeedPost item) => item.id == updatedPost.id,
    );
    if (index == -1) {
      return _favoritesState.copyWith(
        items: <FeedPost>[updatedPost, ..._favoritesState.items],
      );
    }

    final List<FeedPost> nextItems = List<FeedPost>.of(_favoritesState.items);
    nextItems[index] = updatedPost;
    return _favoritesState.copyWith(items: nextItems);
  }

  FeedState _removeFavoritePost(String postId) {
    return _favoritesState.copyWith(
      items: _favoritesState.items
          .where((FeedPost item) => item.id != postId)
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
