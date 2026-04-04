import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../design/editorial_tokens.dart";

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.session, required this.onLogout});

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const List<_PrayerFeedItem> _items = <_PrayerFeedItem>[
    _PrayerFeedItem(
      author: "ANONYMOUS",
      timeAgo: "2H AGO",
      message:
          "\"Please pray for my grandmother's health. She is facing surgery tomorrow morning, and our family is seeking strength and peace through this night.\"",
      tone: _PrayerCardTone.soft,
    ),
    _PrayerFeedItem(
      author: "ANONYMOUS",
      timeAgo: "5H AGO",
      message:
          "\"For peace in my community. There has been so much tension lately. I pray for open hearts and ears that listen before they speak.\"",
      tone: _PrayerCardTone.lined,
    ),
    _PrayerFeedItem(
      author: "ANONYMOUS",
      timeAgo: "8H AGO",
      message:
          "\"Praying for guidance in my career. I feel lost at a crossroads. I ask for clarity to see the path that leads to serving others better.\"",
      tone: _PrayerCardTone.soft,
    ),
  ];

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditorialColors.surface,
      appBar: AppBar(
        backgroundColor: EditorialColors.surface.withValues(alpha: 0.94),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 20),
          color: EditorialColors.primary,
          onPressed: _showAccountSheet,
        ),
        centerTitle: true,
        title: const Text(
          "Prayers",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: EditorialColors.onSurface,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            color: EditorialColors.primary,
            onPressed: () => _showNotice("Search is not connected yet."),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
          children: <Widget>[
            const _FeedHeader(),
            const SizedBox(height: 56),
            for (int index = 0; index < _items.length; index++) ...<Widget>[
              _PrayerCard(
                item: _items[index],
                onLove: () => _showNotice("Love sent."),
                onAmen: () => _showNotice("Amen offered."),
                onWithYou: () => _showNotice("You are with them."),
              ),
              if (index < _items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      child: Divider(
                        color: Color(0x33ADB3B4),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            const _FeedFooter(),
          ],
        ),
      ),
      bottomNavigationBar: _FeedBottomBar(
        selectedIndex: _selectedTabIndex,
        onSelected: _handleBottomTabSelected,
      ),
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
        _showNotice("Prayer feed");
      case 1:
        _showNotice("Create prayer is not connected yet.");
      case 2:
        _showNotice("Activity is not connected yet.");
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "A collective breath.",
          style: TextStyle(
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: EditorialColors.onSurface,
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: 48,
          child: Divider(color: Color(0x4DADB3B4), thickness: 1, height: 1),
        ),
        SizedBox(height: 24),
        Text(
          "Join a silent community of voices.\nShare your burdens, find solace in the\nshared spirit of hope.",
          style: TextStyle(
            fontSize: 17,
            height: 1.75,
            color: EditorialColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.item,
    required this.onLove,
    required this.onAmen,
    required this.onWithYou,
  });

  final _PrayerFeedItem item;
  final VoidCallback onLove;
  final VoidCallback onAmen;
  final VoidCallback onWithYou;

  @override
  Widget build(BuildContext context) {
    final bool lined = item.tone == _PrayerCardTone.lined;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              item.author,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: EditorialColors.onSurfaceMuted,
              ),
            ),
            const Spacer(),
            Text(
              item.timeAgo,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.3,
                color: EditorialColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: lined
                ? EditorialColors.surfaceLowest
                : EditorialColors.surfaceLow,
            border: lined
                ? const Border(
                    left: BorderSide(
                      color: EditorialColors.primaryDim,
                      width: 2,
                    ),
                  )
                : null,
            borderRadius: lined ? null : BorderRadius.circular(12),
          ),
          child: Text(
            item.message,
            style: TextStyle(
              fontSize: 19,
              height: 1.8,
              fontWeight: FontWeight.w300,
              fontStyle: lined ? FontStyle.normal : FontStyle.italic,
              color: EditorialColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            _PrayerAction(
              icon: Icons.favorite_border,
              hoverIcon: Icons.favorite,
              label: "LOVE",
              onTap: onLove,
            ),
            const SizedBox(width: 22),
            _PrayerAction(
              icon: Icons.front_hand_outlined,
              hoverIcon: Icons.front_hand,
              label: "AMEN",
              onTap: onAmen,
            ),
            const SizedBox(width: 22),
            _PrayerAction(
              icon: Icons.volunteer_activism_outlined,
              hoverIcon: Icons.volunteer_activism,
              label: "WITH YOU",
              iconSize: 18,
              onTap: onWithYou,
            ),
          ],
        ),
      ],
    );
  }
}

class _PrayerAction extends StatefulWidget {
  const _PrayerAction({
    required this.icon,
    required this.hoverIcon,
    required this.label,
    required this.onTap,
    this.iconSize = 16,
  });

  final IconData icon;
  final IconData hoverIcon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;

  @override
  State<_PrayerAction> createState() => _PrayerActionState();
}

class _PrayerActionState extends State<_PrayerAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: Icon(
                    _isHovered ? widget.hoverIcon : widget.icon,
                    size: widget.iconSize,
                    color: EditorialColors.outline,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: EditorialColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(
          width: 48,
          child: Divider(color: Color(0x4DADB3B4), thickness: 1, height: 1),
        ),
        SizedBox(height: 16),
        Text(
          "PEACE BE WITH YOU",
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.0,
            color: EditorialColors.outline,
          ),
        ),
      ],
    );
  }
}

class _FeedBottomBar extends StatelessWidget {
  const _FeedBottomBar({required this.selectedIndex, required this.onSelected});

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
            _BottomNavItem(
              icon: Icons.home_filled,
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            _BottomNavItem(
              icon: Icons.favorite_border,
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
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
            icon,
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

class _PrayerFeedItem {
  const _PrayerFeedItem({
    required this.author,
    required this.timeAgo,
    required this.message,
    required this.tone,
  });

  final String author;
  final String timeAgo;
  final String message;
  final _PrayerCardTone tone;
}

enum _PrayerCardTone { soft, lined }
