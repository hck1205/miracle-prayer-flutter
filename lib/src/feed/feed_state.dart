import "feed_models.dart";

class FeedState {
  const FeedState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.nextCursor,
    required this.errorMessage,
  });

  const FeedState.initial()
    : items = const <FeedPost>[],
      isLoading = false,
      isLoadingMore = false,
      hasMore = true,
      nextCursor = null,
      errorMessage = null;

  final List<FeedPost> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;

  FeedState copyWith({
    List<FeedPost>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    bool clearNextCursor = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
