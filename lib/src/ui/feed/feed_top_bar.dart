import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";

class FeedTopBar extends StatelessWidget {
  const FeedTopBar({
    super.key,
    required this.onMenuTap,
    required this.onSearchTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Center(
            child: Text(
              "Prayers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: EditorialColors.onSurface,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 20),
              color: EditorialColors.primary,
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.search, size: 20),
              color: EditorialColors.primary,
              onPressed: onSearchTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            ),
          ),
        ],
      ),
    );
  }
}
