import "package:flutter/foundation.dart";

import "feed_api_client.dart";
import "feed_error_message.dart";
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
