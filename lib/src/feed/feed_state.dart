import "feed_models.dart";

class FeedState {
  const FeedState({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
  });

  const FeedState.initial()
    : items = const <FeedPost>[],
      isLoading = false,
      errorMessage = null;

  final List<FeedPost> items;
  final bool isLoading;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;

  FeedState copyWith({
    List<FeedPost>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
