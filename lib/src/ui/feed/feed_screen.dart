import "dart:async";

import "package:flutter/material.dart";

import "../../app_config.dart";
import "../../auth/auth_models.dart";
import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_api_client.dart";
import "../../feed/feed_controller.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "feed_scroll_pagination.dart";
import "feed_top_bar.dart";
import "feed_view.dart";

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.session, required this.onLogout});

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late final FeedController _controller;
  late final ScrollController _scrollController;
  late final FeedScrollPagination _scrollPagination;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = FeedController(
      feedApiClient: FeedApiClient(baseUrl: AppConfig.normalizedBackendBaseUrl),
      accessToken: widget.session.accessToken,
    );
    _scrollPagination = FeedScrollPagination(
      scrollController: _scrollController,
      onLoadMore: () => unawaited(_controller.loadMore()),
    )..attach();
    unawaited(_controller.bootstrap());
  }

  @override
  void dispose() {
    _scrollPagination.detach();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          backgroundColor: EditorialColors.surface,
          body: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: EditorialCenteredViewport(
                  maxWidth: 620,
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
                  child: FeedTopBar(
                    onMenuTap: _showAccountSheet,
                    onSearchTap: () =>
                        _showNotice("Search is not connected yet."),
                  ),
                ),
              ),
              Expanded(
                child: FeedView(
                  state: _controller.state,
                  scrollController: _scrollController,
                  selectedTabIndex: _selectedTabIndex,
                  onSelectedTab: _handleBottomTabSelected,
                  onRetry: _controller.refreshFeed,
                  onLoadMore: _controller.loadMore,
                  onReact: _handleReactionSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: EditorialColors.surfaceLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.session.user.name ?? widget.session.user.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: EditorialColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.session.user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: EditorialColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onLogout();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text("Log out"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EditorialColors.onSurface,
                      side: const BorderSide(
                        color: EditorialColors.outlineVariant,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleBottomTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    switch (index) {
      case 0:
        unawaited(_controller.refreshFeed());
        _showNotice("Prayer feed refreshed.");
        break;
      case 1:
        _showNotice("Create prayer is not connected yet.");
        break;
      case 2:
        _showNotice("Activity is not connected yet.");
        break;
    }
  }

  void _handleReactionSelected(FeedPost post, FeedReactionKind reaction) {
    unawaited(_controller.reactToPost(post.id, reaction));
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
