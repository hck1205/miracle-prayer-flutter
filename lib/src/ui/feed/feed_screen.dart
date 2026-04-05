import "dart:async";

import "package:flutter/material.dart";

import "../../app_config.dart";
import "../../auth/auth_models.dart";
import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_api_client.dart";
import "../../feed/feed_controller.dart";
import "../../feed/feed_error_message.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_reaction.dart";
import "feed_bottom_bar.dart";
import "feed_create_view.dart";
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
  static const bool _defaultAnonymousPosting = true;

  late final FeedController _controller;
  late final ScrollController _scrollController;
  late final FeedScrollPagination _scrollPagination;
  late final TextEditingController _composerController;
  FeedDraft? _activeDraft;
  FeedPost? _editingPost;
  int _selectedTabIndex = 0;
  bool _postAnonymously = _defaultAnonymousPosting;
  bool _isSubmittingComposer = false;
  bool _isCheckingDraftEntry = false;
  String _composerBaselineBody = "";
  bool _composerBaselineAnonymous = _defaultAnonymousPosting;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _composerController = TextEditingController()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
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
    _composerController.dispose();
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
              Expanded(child: _buildCurrentTab()),
              EditorialCenteredViewport(
                maxWidth: 620,
                padding: EdgeInsets.zero,
                child: FeedBottomBar(
                  selectedIndex: _selectedTabIndex,
                  onSelected: _handleBottomTabSelected,
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
    if (index == _selectedTabIndex) {
      if (index == 0) {
        unawaited(_controller.refreshFeed());
      }
      return;
    }

    if (_selectedTabIndex == 1 && index != 1) {
      if (_editingPost != null) {
        _exitComposer(nextTabIndex: index);
      } else {
        unawaited(_handleCreateCancel(nextTabIndex: index));
      }
      return;
    }

    setState(() {
      if (index == 1 &&
          _editingPost == null &&
          _activeDraft == null &&
          _composerController.text.trim().isEmpty) {
        _postAnonymously = _defaultAnonymousPosting;
        _composerBaselineBody = "";
        _composerBaselineAnonymous = _defaultAnonymousPosting;
      }
      _selectedTabIndex = index;
    });

    if (index == 1) {
      unawaited(_prepareCreateComposerEntry());
    }
  }

  void _handleReactionSelected(FeedPost post, FeedReactionKind reaction) {
    unawaited(_controller.reactToPost(post.id, reaction));
  }

  void _handleEditSelected(FeedPost post) {
    _composerController.text = post.body;
    _composerController.selection = TextSelection.collapsed(
      offset: _composerController.text.length,
    );

    setState(() {
      _activeDraft = null;
      _editingPost = post;
      _postAnonymously = post.isAnonymous;
      _composerBaselineBody = post.body;
      _composerBaselineAnonymous = post.isAnonymous;
      _selectedTabIndex = 1;
    });
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 1:
        return FeedCreateView(
          title: _editingPost == null ? "Write a Prayer" : "Edit Prayer",
          identityLabel: widget.session.user.name ?? widget.session.user.email,
          bodyController: _composerController,
          isAnonymous: _postAnonymously,
          isSubmitting: _isSubmittingComposer,
          onAnonymousChanged: (bool value) {
            setState(() {
              _postAnonymously = value;
            });
          },
          primaryActionLabel: _editingPost == null ? "SHARE" : "UPDATE",
          onPrimaryAction: () => _editingPost == null
              ? _submitComposer()
              : _submitEditComposer(),
          secondaryActionLabel: "Cancel",
          onSecondaryAction: () => _editingPost == null
              ? _handleCreateCancel()
              : _exitComposer(),
          onTagTap: () => _showNotice("Tagging is not connected yet."),
          onQuoteTap: () =>
              _showNotice("Quote templates are not connected yet."),
        );
      case 2:
        return const _ActivityPlaceholderView();
      case 0:
      default:
        return FeedView(
          state: _controller.state,
          scrollController: _scrollController,
          onRetry: _controller.refreshFeed,
          onLoadMore: _controller.loadMore,
          onReact: _handleReactionSelected,
          onEdit: _handleEditSelected,
        );
    }
  }

  Future<void> _submitComposer() async {
    final String body = _composerController.text.trim();
    final FeedVisibility visibility = _postAnonymously
        ? FeedVisibility.anonymous
        : FeedVisibility.public;

    if (body.isEmpty) {
      _showNotice("Write your prayer before continuing.");
      return;
    }

    if (_isSubmittingComposer) {
      return;
    }

    setState(() {
      _isSubmittingComposer = true;
    });

    try {
      if (_activeDraft == null) {
        await _controller.createPost(
          body: body,
          visibility: visibility,
          saveAsDraft: false,
        );
      } else {
        await _controller.updatePost(
          postId: _activeDraft!.id,
          body: body,
          visibility: visibility,
          publish: true,
        );
      }

      if (!mounted) {
        return;
      }

      _resetComposerState(nextTabIndex: 0);
      await _controller.refreshFeed();
      _showNotice("Prayer shared.");
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmittingComposer = false;
      });
      _showNotice(mapFeedErrorMessage(error));
    }
  }

  Future<void> _submitEditComposer() async {
    final FeedPost? editingPost = _editingPost;
    final String body = _composerController.text.trim();

    if (editingPost == null) {
      _showNotice("There is no post selected for editing.");
      return;
    }

    if (body.isEmpty) {
      _showNotice("Write your prayer before continuing.");
      return;
    }

    if (_isSubmittingComposer) {
      return;
    }

    setState(() {
      _isSubmittingComposer = true;
    });

    try {
      await _controller.updatePost(
        postId: editingPost.id,
        body: body,
        visibility: _postAnonymously
            ? FeedVisibility.anonymous
            : FeedVisibility.public,
      );

      if (!mounted) {
        return;
      }

      _resetComposerState(nextTabIndex: 0);
      await _controller.refreshFeed();
      _showNotice("Prayer updated.");
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmittingComposer = false;
      });
      _showNotice(mapFeedErrorMessage(error));
    }
  }

  Future<void> _handleCreateCancel({int nextTabIndex = 0}) async {
    if (_isSubmittingComposer) {
      return;
    }

    if (!_hasDraftableComposerChanges) {
      _exitComposer(nextTabIndex: nextTabIndex);
      return;
    }

    final String body = _composerController.text.trim();

    setState(() {
      _isSubmittingComposer = true;
    });

    try {
      if (_activeDraft == null) {
        await _controller.createPost(
          body: body,
          visibility: _postAnonymously
              ? FeedVisibility.anonymous
              : FeedVisibility.public,
          saveAsDraft: true,
        );
      } else {
        await _controller.updatePost(
          postId: _activeDraft!.id,
          body: body,
          visibility: _postAnonymously
              ? FeedVisibility.anonymous
              : FeedVisibility.public,
        );
      }

      if (!mounted) {
        return;
      }

      _resetComposerState(nextTabIndex: nextTabIndex);
      _showNotice("Draft saved.", duration: const Duration(milliseconds: 1400));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmittingComposer = false;
      });
      _showNotice(mapFeedErrorMessage(error));
    }
  }

  Future<void> _prepareCreateComposerEntry() async {
    if (_editingPost != null ||
        _activeDraft != null ||
        _isCheckingDraftEntry ||
        _composerController.text.trim().isNotEmpty) {
      return;
    }

    _isCheckingDraftEntry = true;

    try {
      final FeedDraft? latestDraft = await _controller.fetchLatestDraft();

      if (!mounted || _selectedTabIndex != 1 || _editingPost != null) {
        return;
      }

      if (latestDraft == null) {
        setState(() {
          _composerBaselineBody = "";
          _composerBaselineAnonymous = _defaultAnonymousPosting;
          _postAnonymously = _defaultAnonymousPosting;
        });
        return;
      }

      final _DraftResumeAction? action = await _showDraftResumeDialog();

      if (!mounted || _selectedTabIndex != 1 || _editingPost != null) {
        return;
      }

      if (action == _DraftResumeAction.continueWriting) {
        _restoreDraft(latestDraft);
        return;
      }

      if (action == _DraftResumeAction.startNew) {
        try {
          await _controller.discardDraft(latestDraft.id);
        } catch (error) {
          if (mounted) {
            _showNotice(mapFeedErrorMessage(error));
          }
        }

        if (!mounted) {
          return;
        }

        _resetComposerState(nextTabIndex: 1);
      }
    } catch (error) {
      if (mounted) {
        _showNotice(mapFeedErrorMessage(error));
      }
    } finally {
      _isCheckingDraftEntry = false;
    }
  }

  Future<_DraftResumeAction?> _showDraftResumeDialog() {
    return showDialog<_DraftResumeAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EditorialColors.surfaceLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Saved draft found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: EditorialColors.onSurface,
            ),
          ),
          content: const Text(
            "You already have a prayer draft. Would you like to continue writing it or start a new one?",
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: EditorialColors.onSurfaceMuted,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(_DraftResumeAction.startNew),
              style: OutlinedButton.styleFrom(
                foregroundColor: EditorialColors.onSurfaceMuted,
                side: const BorderSide(color: EditorialColors.outlineVariant),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text("Start New"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(_DraftResumeAction.continueWriting),
              style: FilledButton.styleFrom(
                backgroundColor: EditorialColors.primary,
                foregroundColor: EditorialColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text("Continue Writing"),
            ),
          ],
        );
      },
    );
  }

  void _restoreDraft(FeedDraft draft) {
    _composerController.text = draft.body;
    _composerController.selection = TextSelection.collapsed(
      offset: _composerController.text.length,
    );

    setState(() {
      _activeDraft = draft;
      _editingPost = null;
      _postAnonymously = draft.isAnonymous;
      _composerBaselineBody = draft.body;
      _composerBaselineAnonymous = draft.isAnonymous;
      _selectedTabIndex = 1;
    });
  }

  bool get _hasDraftableComposerChanges {
    final bool bodyChanged = _composerController.text != _composerBaselineBody;
    final bool visibilityChanged =
        _postAnonymously != _composerBaselineAnonymous;

    if (!bodyChanged && !visibilityChanged) {
      return false;
    }

    return _composerController.text.trim().isNotEmpty;
  }

  void _exitComposer({int nextTabIndex = 0}) {
    _resetComposerState(nextTabIndex: nextTabIndex);
  }

  void _resetComposerState({required int nextTabIndex}) {
    _composerController.clear();
    setState(() {
      _activeDraft = null;
      _editingPost = null;
      _postAnonymously = _defaultAnonymousPosting;
      _isSubmittingComposer = false;
      _composerBaselineBody = "";
      _composerBaselineAnonymous = _defaultAnonymousPosting;
      _selectedTabIndex = nextTabIndex;
    });
  }

  void _showNotice(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: duration ?? const Duration(seconds: 4)),
      );
  }
}

enum _DraftResumeAction { continueWriting, startNew }

class _ActivityPlaceholderView extends StatelessWidget {
  const _ActivityPlaceholderView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: EditorialCenteredViewport(
          maxWidth: 620,
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Text(
                  "Activity will gather here.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: EditorialColors.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Reactions, encouragement, and future updates are not connected yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: EditorialColors.onSurfaceMuted,
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
