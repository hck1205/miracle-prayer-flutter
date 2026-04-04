import "package:flutter/foundation.dart";

import "feed_api_client.dart";
import "feed_error_message.dart";
import "feed_models.dart";
import "feed_reaction.dart";
import "feed_state.dart";

class FeedController extends ChangeNotifier {
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

    _didBootstrap = true;
    await refreshFeed();
  }

  Future<void> refreshFeed() async {
    if (_state.isLoading) {
      return;
    }

    _updateState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final items = await _feedApiClient.fetchFeed(_accessToken);
      _updateState(
        _state.copyWith(items: items, isLoading: false, clearError: true),
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

  Future<void> reactToPost(String postId, FeedReactionKind reaction) async {
    try {
      final FeedPostReactionResult result = await _feedApiClient.reactToPost(
        _accessToken,
        postId: postId,
        reaction: reaction,
      );

      final List<FeedPost> nextItems = _state.items
          .map((FeedPost item) {
            if (item.id != result.postId) {
              return item;
            }

            return item.copyWith(
              reactionCount: result.reactionCount,
              reactionSummary: result.reactionSummary,
              viewerReaction: result.viewerReaction,
              clearViewerReaction: result.viewerReaction == null,
            );
          })
          .toList(growable: false);

      _updateState(
        _state.copyWith(items: nextItems, clearError: true),
      );
    } catch (error) {
      _updateState(
        _state.copyWith(errorMessage: mapFeedErrorMessage(error)),
      );
    }
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
