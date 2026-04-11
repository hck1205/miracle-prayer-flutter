import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "feed_styles.dart";

class FeedFooter extends StatelessWidget {
  const FeedFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        EditorialDivider(),
        SizedBox(height: 16),
        Text("PEACE BE WITH YOU", style: FeedStyles.footerLabel),
      ],
    );
  }
}

class FeedBottomBar extends StatelessWidget {
  const FeedBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: EditorialColors.surface.withValues(alpha: 0.94),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            BottomNavItem(
              icon: Icons.home_filled,
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            BottomNavItem(
              icon: Icons.add_circle_outline,
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            BottomNavItem(
              icon: Icons.bookmark_border_rounded,
              selectedIcon: Icons.bookmark_rounded,
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? EditorialColors.surfaceContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            selected ? (selectedIcon ?? icon) : icon,
            size: 20,
            color: selected
                ? EditorialColors.onSurface
                : EditorialColors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
