import "../../feed/feed_controller.dart";
import "../../feed/feed_models.dart";

FeedPost? findFeedPostById(FeedController controller, String postId) {
  // Detail screens can be opened from feed, favorites, urgent, and search
  // results, so the lookup checks every in-memory source before falling back.
  for (final FeedPost item in controller.state.items) {
    if (item.id == postId) {
      return item;
    }
  }

  for (final FeedPost item in controller.favoritesState.items) {
    if (item.id == postId) {
      return item;
    }
  }

  for (final FeedPost item in controller.urgentState.items) {
    if (item.id == postId) {
      return item;
    }
  }

  for (final FeedPost item in controller.searchState.items) {
    if (item.id == postId) {
      return item;
    }
  }

  return null;
}
