import "dart:async";

import "package:flutter/material.dart";

import "../../auth/auth_models.dart";
import "../../core/network/api_exception.dart";
import "../../design/editorial_components.dart";
import "../../design/editorial_tokens.dart";
import "../../feed/feed_controller.dart";
import "../../feed/feed_error_message.dart";
import "../../feed/feed_models.dart";
import "../../feed/feed_report.dart";
import "../../feed/feed_reaction.dart";
import "feed_account_sheet.dart";
import "feed_bottom_bar.dart";
import "feed_create_view.dart";
import "feed_edit_expired_dialog.dart";
import "feed_delete_confirm_dialog.dart";
import "feed_draft_resume_dialog.dart";
import "feed_reported_notice_dialog.dart";
import "feed_report_dialog.dart";
import "feed_scroll_pagination.dart";
import "feed_top_bar.dart";
import "feed_view.dart";

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.session,
    required this.onLogout,
    required this.controller,
  });

  final AuthSession session;
  final VoidCallback onLogout;
  final FeedController controller;

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
  FeedDraft? _cachedLatestDraft;
  FeedPost? _editingPost;
  int _selectedTabIndex = 0;
  bool _postAnonymously = _defaultAnonymousPosting;
  bool _isSubmittingComposer = false;
  bool _isCheckingDraftEntry = false;
  bool _hasResolvedLatestDraft = false;
  String _composerBaselineBody = "";
  bool _composerBaselineAnonymous = _defaultAnonymousPosting;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _composerController = TextEditingController();
    _controller = widget.controller;
    _scrollPagination = FeedScrollPagination(
      scrollController: _scrollController,
      onLoadMore: () => unawaited(_controller.loadMore()),
    )..attach();
  }

  @override
  void dispose() {
    _scrollPagination.detach();
    _scrollController.dispose();
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                onSearchTap: () => _showNotice("Search is not connected yet."),
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
  }

  void _showAccountSheet() {
    unawaited(
      showFeedAccountSheet(
        context,
        session: widget.session,
        onLogout: widget.onLogout,
      ),
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
      // Leaving the composer should follow the same draft-preserving flow as
      // tapping Cancel so users do not lose in-progress writing.
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
    if (!post.isWithinEditWindow) {
      unawaited(showFeedEditExpiredDialog(context));
      return;
    }

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

  Future<void> _handleDeleteSelected(FeedPost post) async {
    final bool confirmed = await showFeedDeleteConfirmDialog(context);
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await _controller.deletePost(post.id);

      if (!mounted) {
        return;
      }

      _showNotice("Prayer deleted.");
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (error is ApiException &&
          error.message == "You already reported this prayer.") {
        await showFeedReportedNoticeDialog(context);
        return;
      }

      _showNotice(mapFeedErrorMessage(error));
    }
  }

  Future<void> _handleReportSelected(FeedPost post) async {
    final FeedReportSubmission? submission = await showFeedReportDialog(
      context,
    );
    if (submission == null || !mounted) {
      return;
    }

    try {
      await _controller.reportPost(post.id, submission);

      if (!mounted) {
        return;
      }

      _showNotice("Report submitted. Thank you.");
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showNotice(mapFeedErrorMessage(error));
    }
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
          onPrimaryAction: () =>
              _editingPost == null ? _submitComposer() : _submitEditComposer(),
          secondaryActionLabel: "Cancel",
          onSecondaryAction: () =>
              _editingPost == null ? _handleCreateCancel() : _exitComposer(),
          onTagTap: () => _showNotice("Tagging is not connected yet."),
          onQuoteTap: () =>
              _showNotice("Quote templates are not connected yet."),
        );
      case 2:
        return const _ActivityPlaceholderView();
      case 0:
      default:
        // Only the feed tab listens to controller changes so typing inside the
        // composer no longer rebuilds the full scaffold.
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            return FeedView(
              state: _controller.state,
              scrollController: _scrollController,
              onRetry: _controller.refreshFeed,
              onLoadMore: _controller.loadMore,
              onReact: _handleReactionSelected,
              onEdit: _handleEditSelected,
              onDelete: (FeedPost post) =>
                  unawaited(_handleDeleteSelected(post)),
              onReport: (FeedPost post) =>
                  unawaited(_handleReportSelected(post)),
            );
          },
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
      // Publishing a resumed draft updates the existing post instead of
      // creating a duplicate record with the same content.
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

      _cacheLatestDraft(null);
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

    // A blank or unchanged composer can exit immediately. We only persist
    // meaningful edits so toggling in and out of the screen stays fast.
    if (!_hasDraftableComposerChanges) {
      _exitComposer(nextTabIndex: nextTabIndex);
      return;
    }

    final String body = _composerController.text.trim();
    final FeedVisibility visibility = _postAnonymously
        ? FeedVisibility.anonymous
        : FeedVisibility.public;
    final FeedDraft? activeDraft = _activeDraft;

    setState(() {
      _isSubmittingComposer = true;
    });

    try {
      if (activeDraft == null) {
        final result = await _controller.createPost(
          body: body,
          visibility: visibility,
          saveAsDraft: true,
        );
        _cacheLatestDraft(
          result.isDraft
              ? FeedDraft(
                  id: result.id,
                  body: body,
                  visibility: visibility,
                  updatedAt: result.createdAt,
                  createdAt: result.createdAt,
                )
              : null,
        );
      } else {
        final result = await _controller.updatePost(
          postId: activeDraft.id,
          body: body,
          visibility: visibility,
        );
        _cacheLatestDraft(
          result.status == "DRAFT"
              ? FeedDraft(
                  id: result.id,
                  body: result.body,
                  visibility: result.visibility,
                  updatedAt: result.updatedAt,
                  createdAt: activeDraft.createdAt,
                )
              : null,
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
    // Skip the resume flow if the user is already editing something or has
    // local text in the composer. That keeps the prompt from interrupting
    // intentional in-progress work.
    if (_editingPost != null ||
        _activeDraft != null ||
        _isCheckingDraftEntry ||
        _composerController.text.trim().isNotEmpty) {
      return;
    }

    _isCheckingDraftEntry = true;

    try {
      final FeedDraft? latestDraft =
          await _resolveLatestDraftForComposerEntry();

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

      final FeedDraftResumeAction? action = await showFeedDraftResumeDialog(
        context,
      );

      if (!mounted || _selectedTabIndex != 1 || _editingPost != null) {
        return;
      }

      if (action == FeedDraftResumeAction.continueWriting) {
        _restoreDraft(latestDraft);
        return;
      }

      if (action == FeedDraftResumeAction.startNew) {
        try {
          await _controller.discardDraft(latestDraft.id);
          _cacheLatestDraft(null);
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

  void _restoreDraft(FeedDraft draft) {
    _composerController.text = draft.body;
    _composerController.selection = TextSelection.collapsed(
      offset: _composerController.text.length,
    );

    _cacheLatestDraft(draft);
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

    // We only auto-save non-empty drafts. That avoids leaving behind empty
    // records when the user opens the composer and immediately backs out.
    if (!bodyChanged && !visibilityChanged) {
      return false;
    }

    return _composerController.text.trim().isNotEmpty;
  }

  Future<FeedDraft?> _resolveLatestDraftForComposerEntry() async {
    if (_hasResolvedLatestDraft) {
      return _cachedLatestDraft;
    }

    // Reuse the latest draft result while the session stays alive so moving
    // between tabs does not repeatedly hit the draft endpoint.
    final FeedDraft? latestDraft = await _controller.fetchLatestDraft();
    _cacheLatestDraft(latestDraft);
    return latestDraft;
  }

  void _exitComposer({int nextTabIndex = 0}) {
    _resetComposerState(nextTabIndex: nextTabIndex);
  }

  void _cacheLatestDraft(FeedDraft? draft) {
    _cachedLatestDraft = draft;
    _hasResolvedLatestDraft = true;
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
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 2),
        ),
      );
  }
}

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
