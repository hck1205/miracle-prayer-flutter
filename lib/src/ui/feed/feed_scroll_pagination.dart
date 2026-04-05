import "package:flutter/material.dart";

class FeedScrollPagination {
  FeedScrollPagination({
    required this.scrollController,
    required this.onLoadMore,
    this.preloadThreshold = 1200,
  });

  final ScrollController scrollController;
  final VoidCallback onLoadMore;
  final double preloadThreshold;

  void attach() {
    scrollController.addListener(_handleScroll);
  }

  void detach() {
    scrollController.removeListener(_handleScroll);
  }

  void _handleScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    // Trigger a little early so the next page can arrive before the user hits
    // the end of the current list.
    if (scrollController.position.extentAfter < preloadThreshold) {
      onLoadMore();
    }
  }
}
