import "../../feed/feed_controller.dart";
import "../../feed/feed_models.dart";

FeedPost? findFeedPostById(FeedController controller, String postId) {
  // Detail screens can be opened from both the main feed and the urgent
  // carousel, so the lookup checks every in-memory source before falling back.
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

  return null;
}
