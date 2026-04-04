import "package:flutter/material.dart";

enum FeedReactionKind { amen, love, withYou, peace }

class FeedReactionOption {
  const FeedReactionOption({
    required this.kind,
    required this.label,
    this.emoji,
    this.icon,
  });

  final FeedReactionKind kind;
  final String label;
  final String? emoji;
  final IconData? icon;
}

abstract final class FeedReactions {
  static const FeedReactionOption amen = FeedReactionOption(
    kind: FeedReactionKind.amen,
    label: "AMEN",
    icon: Icons.front_hand_outlined,
  );

  static const FeedReactionOption love = FeedReactionOption(
    kind: FeedReactionKind.love,
    label: "LOVE",
    icon: Icons.favorite_border,
  );

  static const FeedReactionOption withYou = FeedReactionOption(
    kind: FeedReactionKind.withYou,
    label: "WITH YOU",
    icon: Icons.volunteer_activism_outlined,
  );

  static const FeedReactionOption peace = FeedReactionOption(
    kind: FeedReactionKind.peace,
    label: "PEACE",
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
