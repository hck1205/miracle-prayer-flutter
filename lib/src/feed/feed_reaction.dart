import "package:flutter/material.dart";

import "../localization/app_strings.dart";

enum FeedReactionKind { amen, love, withYou, peace }

class FeedReactionOption {
  const FeedReactionOption({
    required this.kind,
    this.emoji,
    this.icon,
  });

  final FeedReactionKind kind;
  final String? emoji;
  final IconData? icon;

  String label(AppStrings strings) {
    return switch (kind) {
      FeedReactionKind.amen => strings.reactionAmen(),
      FeedReactionKind.love => strings.reactionLove(),
      FeedReactionKind.withYou => strings.reactionWithYou(),
      FeedReactionKind.peace => strings.reactionPeace(),
    };
  }
}

abstract final class FeedReactions {
  static const FeedReactionOption amen = FeedReactionOption(
    kind: FeedReactionKind.amen,
    icon: Icons.front_hand_outlined,
  );

  static const FeedReactionOption love = FeedReactionOption(
    kind: FeedReactionKind.love,
    icon: Icons.favorite_border,
  );

  static const FeedReactionOption withYou = FeedReactionOption(
    kind: FeedReactionKind.withYou,
    icon: Icons.volunteer_activism_outlined,
  );

  static const FeedReactionOption peace = FeedReactionOption(
    kind: FeedReactionKind.peace,
    icon: Icons.spa_outlined,
  );

  static const List<FeedReactionOption> all = <FeedReactionOption>[
    amen,
    love,
    withYou,
    peace,
  ];

  static FeedReactionOption fromKind(FeedReactionKind kind) {
    return switch (kind) {
      FeedReactionKind.amen => amen,
      FeedReactionKind.love => love,
      FeedReactionKind.withYou => withYou,
      FeedReactionKind.peace => peace,
    };
  }
}
