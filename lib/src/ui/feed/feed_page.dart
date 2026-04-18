import "dart:async";

import "package:flutter/material.dart";

import "../../app_config.dart";
import "../../auth/auth_models.dart";
import "../../feed/feed_api_client.dart";
import "../../feed/feed_controller.dart";
import "../../personal_prayer/personal_prayer_controller.dart";
import "feed_screen.dart";

class FeedPageShell extends StatefulWidget {
  const FeedPageShell({
    super.key,
    required this.session,
    required this.onLogout,
    required this.onUpdateProfileName,
  });

  final AuthSession session;
  final VoidCallback onLogout;
  final Future<void> Function({required String name}) onUpdateProfileName;

  @override
  State<FeedPageShell> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPageShell> {
  late final FeedController _controller;
  late final PersonalPrayerController _personalPrayerController;

  @override
  void initState() {
    super.initState();
    // The page owns the controller lifecycle so the screen can stay focused on
    // view state and interaction flow.
    _controller = FeedController(
      feedApiClient: FeedApiClient(baseUrl: AppConfig.normalizedBackendBaseUrl),
      accessToken: widget.session.accessToken,
    );
    _personalPrayerController = PersonalPrayerController(
      userId: widget.session.user.id,
    );
    unawaited(_controller.bootstrap());
  }

  @override
  void dispose() {
    _controller.dispose();
    _personalPrayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeedScreen(
      session: widget.session,
      onLogout: widget.onLogout,
      onUpdateProfileName: widget.onUpdateProfileName,
      controller: _controller,
      personalPrayerController: _personalPrayerController,
    );
  }
}
