import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "../../feed/feed_state.dart";
import "feed_widgets.dart";

class FeedView extends StatelessWidget {
  const FeedView({
    super.key,
    required this.state,
    required this.selectedTabIndex,
    required this.onSelectedTab,
    required this.onRetry,
    required this.onReact,
  });

  final FeedState state;
  final int selectedTabIndex;
  final ValueChanged<int> onSelectedTab;
  final VoidCallback onRetry;
  final void Function(FeedPost post, FeedReactionKind reaction) onReact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              children: <Widget>[
                const FeedHeader(),
                const SizedBox(height: 32),
                if (state.isLoading && !state.hasItems)
                  const _FeedLoadingState()
                else if (state.errorMessage != null && !state.hasItems)
                  _FeedErrorState(
                    message: state.errorMessage!,
                    onRetry: onRetry,
                  )
                else if (!state.hasItems)
                  const _FeedEmptyState()
                else
                  ..._buildFeedItems(state.items),
                const SizedBox(height: 20),
                const FeedFooter(),
              ],
            ),
          ),
        ),
        FeedBottomBar(
          selectedIndex: selectedTabIndex,
          onSelected: onSelectedTab,
        ),
      ],
    );
  }

  List<Widget> _buildFeedItems(List<FeedPost> items) {
    return <Widget>[
      if (state.isLoading) ...<Widget>[
        const Center(child: EditorialInlineLoader(width: 96, height: 2)),
        const SizedBox(height: 24),
      ],
      if (state.errorMessage != null) ...<Widget>[
        EditorialStatusMessage(
          message: state.errorMessage!,
          color: EditorialColors.primary,
        ),
        const SizedBox(height: 24),
      ],
      for (int index = 0; index < items.length; index++) ...<Widget>[
        PrayerCard(
          item: items[index],
          onReact: (FeedReactionKind reaction) => onReact(items[index], reaction),
        ),
        if (index < items.length - 1)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: EditorialDivider()),
          ),
      ],
    ];
  }
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          EditorialInlineLoader(width: 120, height: 2),
          SizedBox(height: 18),
          Text(
            "Loading prayers...",
            style: TextStyle(fontSize: 14, color: EditorialColors.outline),
          ),
        ],
      ),
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  const _FeedErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: <Widget>[
          EditorialStatusMessage(
            message: message,
            color: EditorialColors.primary,
          ),
          const SizedBox(height: 18),
          EditorialSecondaryButton(label: "Try again", onPressed: onRetry),
        ],
      ),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  const _FeedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: <Widget>[
          Text(
            "No prayers yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: EditorialColors.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "The feed will appear here once stories begin to gather.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
