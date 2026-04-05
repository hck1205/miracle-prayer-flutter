import "package:flutter/material.dart";

import "../../design/editorial_components.dart";
import "feed_styles.dart";

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("A collective breath.", style: FeedStyles.headerTitle),
        SizedBox(height: 16),
        EditorialDivider(),
        SizedBox(height: 24),
        Text(
          "Join a silent community of voices.\nShare your burdens, find solace in the\nshared spirit of hope.",
          style: FeedStyles.headerBody,
        ),
      ],
    );
  }
}
