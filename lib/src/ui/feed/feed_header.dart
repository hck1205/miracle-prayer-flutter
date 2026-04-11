import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "feed_styles.dart";

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: FeedStyles.headerTitle),
        const SizedBox(height: 16),
        const EditorialDivider(),
        const SizedBox(height: 24),
        Text(body, style: FeedStyles.headerBody),
      ],
    );
  }
}
