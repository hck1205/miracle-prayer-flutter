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
import "feed_detail_screen.dart";
import "feed_edit_expired_dialog.dart";
import "feed_delete_confirm_dialog.dart";
import "feed_draft_resume_dialog.dart";
import "feed_post_lookup.dart";
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
  static const int _minimumSearchLength = 2;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 700);

  late final FeedController _controller;
  late final ScrollController _feedScrollController;
  late final ScrollController _favoritesScrollController;
  late final ScrollController _searchScrollController;
  late final FeedScrollPagination _feedScrollPagination;
  late final FeedScrollPagination _favoritesScrollPagination;
  late final FeedScrollPagination _searchScrollPagination;
  late final TextEditingController _composerController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  FeedDraft? _activeDraft;
  FeedDraft? _cachedLatestDraft;
  FeedUrgentEligibility? _urgentEligibility;
  FeedPost? _editingPost;
  int _selectedTabIndex = 0;
  bool _postAnonymously = _defaultAnonymousPosting;
  bool _postAsUrgent = false;
  bool _isSubmittingComposer = false;
  bool _isCheckingDraftEntry = false;
  bool _isLoadingUrgentEligibility = false;
  bool _hasResolvedLatestDraft = false;
  bool _isSearchMode = false;
  String _composerBaselineBody = "";
  bool _composerBaselineAnonymous = _defaultAnonymousPosting;
  bool _composerBaselineUrgent = false;
  Timer? _searchDebounce;
  String _pendingSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _feedScrollController = ScrollController();
    _favoritesScrollController = ScrollController();
    _searchScrollController = ScrollController();
    _composerController = TextEditingController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _controller = widget.controller;
    _feedScrollPagination = FeedScrollPagination(
      scrollController: _feedScrollController,
      onLoadMore: () => unawaited(_controller.loadMore()),
    )..attach();
    _favoritesScrollPagination = FeedScrollPagination(
      scrollController: _favoritesScrollController,
      onLoadMore: () => unawaited(_controller.loadMoreFavorites()),
    )..attach();
    _searchScrollPagination = FeedScrollPagination(
      scrollController: _searchScrollController,
      onLoadMore: () => unawaited(_controller.loadMoreSearch()),
    )..attach();
  }

  @override
  void dispose() {
    _feedScrollPagination.detach();
    _favoritesScrollPagination.detach();
    _searchScrollPagination.detach();
    _feedScrollController.dispose();
    _favoritesScrollController.dispose();
    _searchScrollController.dispose();
    _composerController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
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
                onSearchTap: _enterSearchMode,
                isSearchMode: _isSearchMode,
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                onSearchChanged: _handleSearchChanged,
                onSearchClose: _closeSearchMode,
              ),
            ),
          ),
          Expanded(
            child: _isSearchMode ? _buildSearchResults() : _buildCurrentTab(),
          ),
          if (!_isSearchMode)
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
    if (_isSearchMode) {
      final int activeTabIndex = _selectedTabIndex;
      _closeSearchMode();
      if (index == activeTabIndex) {
        return;
      }
    }

    if (index == _selectedTabIndex) {
      if (index == 0) {
        unawaited(_controller.refreshFeed());
      } else if (index == 2) {
        unawaited(_controller.refreshFavorites());
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
        _postAsUrgent = false;
        _composerBaselineBody = "";
        _composerBaselineAnonymous = _defaultAnonymousPosting;
        _composerBaselineUrgent = false;
      }
      _selectedTabIndex = index;
    });

    if (index == 1) {
      unawaited(_prepareCreateComposerEntry());
    } else if (index == 2) {
      unawaited(_controller.bootstrapFavorites());
    }
  }

  void _handleReactionSelected(FeedPost post, FeedReactionKind reaction) {
    unawaited(_controller.reactToPost(post.id, reaction));
  }

  Future<bool> _handleFavoriteToggled(FeedPost post) async {
    final bool willFavorite = !post.isFavorited;

    try {
      final bool isFavorited = await _controller.toggleFavorite(post.id);

      if (!mounted) {
        return isFavorited;
      }

      _showNotice(
        isFavorited
            ? "Saved to your favorites."
            : "Removed from your favorites.",
        duration: const Duration(milliseconds: 1400),
      );

      return isFavorited;
    } catch (error) {
      if (!mounted) {
        rethrow;
      }

      if (willFavorite) {
        _showNotice(mapFeedErrorMessage(error));
        rethrow;
      }

      _showNotice(mapFeedErrorMessage(error));
      rethrow;
    }
  }

  Future<void> _handleEditSelected(FeedPost post) async {
    if (!post.isWithinEditWindow) {
      unawaited(showFeedEditExpiredDialog(context));
      return;
    }

    if (_isSearchMode) {
      _closeSearchMode();
    }

    _composerController.text = post.body;
    _composerController.selection = TextSelection.collapsed(
      offset: _composerController.text.length,
    );

    setState(() {
      _activeDraft = null;
      _editingPost = post;
      _postAnonymously = post.isAnonymous;
      _postAsUrgent = post.isUrgent;
      _composerBaselineBody = post.body;
      _composerBaselineAnonymous = post.isAnonymous;
      _composerBaselineUrgent = post.isUrgent;
      _selectedTabIndex = 1;
    });
    unawaited(_loadUrgentEligibility(excludePostId: post.id));
  }

  Future<bool> _handleDeleteSelected(FeedPost post) async {
    final bool confirmed = await showFeedDeleteConfirmDialog(context);
    if (!confirmed || !mounted) {
      return false;
    }

    try {
      await _controller.deletePost(post.id);

      if (!mounted) {
        return false;
      }

      _showNotice("Prayer deleted.");
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      if (error is ApiException &&
          error.message == "You already reported this prayer.") {
        await showFeedReportedNoticeDialog(context);
        return false;
      }

      _showNotice(mapFeedErrorMessage(error));
      return false;
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

  Future<void> _openDetail(FeedPost post) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return FeedDetailScreen(
            controller: _controller,
            initialPost: post,
            onReact: (String postId, FeedReactionKind reaction) {
              return _controller.reactToPost(postId, reaction);
            },
            onToggleFavorite: (String postId) async {
              final FeedPost currentPost =
                  findFeedPostById(_controller, postId) ?? post;
              return _handleFavoriteToggled(currentPost);
            },
            onEdit: _handleEditSelected,
            onDelete: _handleDeleteSelected,
            onReport: _handleReportSelected,
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final String inputQuery = _searchController.text.trim();
        final String query = _controller.searchQuery;
        final bool isQueryTooShort =
            inputQuery.isNotEmpty && inputQuery.length < _minimumSearchLength;

        return FeedView(
          state: _controller.searchState,
          scrollController: _searchScrollController,
          onRetry: _retrySearch,
          onLoadMore: _controller.loadMoreSearch,
          onOpenDetail: (FeedPost post) => unawaited(_openDetail(post)),
          onReact: _handleReactionSelected,
          onToggleFavorite: (FeedPost post) =>
              unawaited(_handleFavoriteToggled(post)),
          onEdit: _handleEditSelected,
          onDelete: (FeedPost post) => unawaited(_handleDeleteSelected(post)),
          onReport: (FeedPost post) => unawaited(_handleReportSelected(post)),
          headerTitle: inputQuery.isEmpty
              ? "Search prayers."
              : isQueryTooShort
              ? "Keep typing."
              : "Search results.",
          headerBody: inputQuery.isEmpty
              ? "Search the community feed by words, topics,\nor short phrases."
              : isQueryTooShort
              ? "Enter at least 2 characters before we search the feed."
              : "Showing prayers that mention \"$query\".",
          loadingMessage: "Searching prayers...",
          emptyTitle: inputQuery.isEmpty
              ? "Start typing to search."
              : isQueryTooShort
              ? "Type 2 or more characters."
              : "No matching prayers found.",
          emptyBody: inputQuery.isEmpty
              ? "Try words like hope, healing, family, or peace."
              : isQueryTooShort
              ? "Short queries create noisy results, so search starts at 2 characters."
              : "Try a shorter phrase or different keywords.",
        );
      },
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 1:
        return FeedCreateView(
          title: _editingPost == null ? "Write a Prayer" : "Edit Prayer",
          identityLabel: widget.session.user.name ?? widget.session.user.email,
          bodyController: _composerController,
          isAnonymous: _postAnonymously,
          isUrgent: _postAsUrgent,
          isUrgentEnabled: _canToggleUrgent,
          isUrgentLoading: _isLoadingUrgentEligibility,
          urgentHelperText: _urgentHelperText,
          isSubmitting: _isSubmittingComposer,
          onAnonymousChanged: (bool value) {
            setState(() {
              _postAnonymously = value;
            });
          },
          onUrgentChanged: (bool value) {
            setState(() {
              _postAsUrgent = value;
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
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            return FeedView(
              state: _controller.favoritesState,
              scrollController: _favoritesScrollController,
              onRetry: _controller.refreshFavorites,
              onLoadMore: _controller.loadMoreFavorites,
              onOpenDetail: (FeedPost post) => unawaited(_openDetail(post)),
              onReact: _handleReactionSelected,
              onToggleFavorite: (FeedPost post) =>
                  unawaited(_handleFavoriteToggled(post)),
              onEdit: _handleEditSelected,
              onDelete: (FeedPost post) =>
                  unawaited(_handleDeleteSelected(post)),
              onReport: (FeedPost post) =>
                  unawaited(_handleReportSelected(post)),
              headerTitle: "Saved prayers.",
              headerBody:
                  "Keep the prayers that stayed with you close.\nReturn here whenever you want to revisit them.",
              loadingMessage: "Loading saved prayers...",
              emptyTitle: "No saved prayers yet.",
              emptyBody:
                  "When a prayer stays with you, tap the bookmark and it will appear here.",
            );
          },
        );
      case 0:
      default:
        // Only the feed tab listens to controller changes so typing inside the
        // composer no longer rebuilds the full scaffold.
        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, _) {
            return FeedView(
              state: _controller.state,
              urgentState: _controller.urgentState,
              scrollController: _feedScrollController,
              onRetry: _controller.refreshFeed,
              onRetryUrgent: _controller.refreshFeed,
              onLoadMore: _controller.loadMore,
              onOpenDetail: (FeedPost post) => unawaited(_openDetail(post)),
              onReact: _handleReactionSelected,
              onToggleFavorite: (FeedPost post) =>
                  unawaited(_handleFavoriteToggled(post)),
              onEdit: _handleEditSelected,
              onDelete: (FeedPost post) =>
                  unawaited(_handleDeleteSelected(post)),
              onReport: (FeedPost post) =>
                  unawaited(_handleReportSelected(post)),
              headerTitle: "A collective breath.",
              headerBody:
                  "Join a silent community of voices.\nShare your burdens, find solace in the\nshared spirit of hope.",
              loadingMessage: "Loading prayers...",
              emptyTitle: "No prayers yet.",
              emptyBody:
                  "The feed will appear here once stories begin to gather.",
            );
          },
        );
      }
  }

  void _enterSearchMode() {
    if (_isSearchMode) {
      _searchFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSearchMode = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _searchFocusNode.requestFocus();
    });
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();

    final String query = value.trim();
    _pendingSearchQuery = query;

    if (query.isEmpty || query.length < _minimumSearchLength) {
      _controller.clearSearch();
      return;
    }

    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted || _pendingSearchQuery != query) {
        return;
      }

      if (_searchScrollController.hasClients) {
        _searchScrollController.jumpTo(0);
      }

      unawaited(_controller.searchPosts(query));
    });
  }

  void _closeSearchMode() {
    _searchDebounce?.cancel();
    _pendingSearchQuery = "";
    _searchController.clear();
    _searchFocusNode.unfocus();
    _controller.clearSearch();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSearchMode = false;
    });
  }

  Future<void> _retrySearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty || query.length < _minimumSearchLength) {
      _controller.clearSearch();
      return;
    }

    _pendingSearchQuery = query;
    await _controller.searchPosts(query, force: true);
  }

  Future<void> _submitComposer() async {
    final String body = _composerController.text.trim();
    final FeedVisibility visibility = _postAnonymously
        ? FeedVisibility.anonymous
        : FeedVisibility.public;
    final FeedPostType? type = _postAsUrgent ? FeedPostType.urgent : null;

    if (body.isEmpty) {
      _showNotice("Write your prayer before continuing.");
      return;
    }

    if (_postAsUrgent && !await _ensureUrgentAvailable()) {
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
          type: type,
          saveAsDraft: false,
        );
      } else {
        await _controller.updatePost(
          postId: _activeDraft!.id,
          body: body,
          visibility: visibility,
          type: type,
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

    if (_postAsUrgent &&
        !await _ensureUrgentAvailable(excludePostId: editingPost.id)) {
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
        type: _postAsUrgent ? FeedPostType.urgent : null,
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
    final FeedPostType? type = _postAsUrgent ? FeedPostType.urgent : null;
    final FeedDraft? activeDraft = _activeDraft;

    setState(() {
      _isSubmittingComposer = true;
    });

    try {
      if (activeDraft == null) {
        final result = await _controller.createPost(
          body: body,
          visibility: visibility,
          type: type,
          saveAsDraft: true,
        );
        _cacheLatestDraft(
          result.isDraft
              ? FeedDraft(
                  id: result.id,
                  body: body,
                  visibility: visibility,
                  type: result.type,
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
          type: type,
        );
        _cacheLatestDraft(
          result.status == "DRAFT"
              ? FeedDraft(
                  id: result.id,
                  body: result.body,
                  visibility: result.visibility,
                  type: result.type,
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
      unawaited(_loadUrgentEligibility());
      final FeedDraft? latestDraft =
          await _resolveLatestDraftForComposerEntry();

      if (!mounted || _selectedTabIndex != 1 || _editingPost != null) {
        return;
      }

      if (latestDraft == null) {
        setState(() {
          _composerBaselineBody = "";
          _composerBaselineAnonymous = _defaultAnonymousPosting;
          _composerBaselineUrgent = false;
          _postAnonymously = _defaultAnonymousPosting;
          _postAsUrgent = false;
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
      _postAsUrgent = draft.isUrgent;
      _composerBaselineBody = draft.body;
      _composerBaselineAnonymous = draft.isAnonymous;
      _composerBaselineUrgent = draft.isUrgent;
      _selectedTabIndex = 1;
    });
  }

  bool get _hasDraftableComposerChanges {
    final bool bodyChanged = _composerController.text != _composerBaselineBody;
    final bool visibilityChanged =
        _postAnonymously != _composerBaselineAnonymous;
    final bool urgentChanged = _postAsUrgent != _composerBaselineUrgent;

    // We only auto-save non-empty drafts. That avoids leaving behind empty
    // records when the user opens the composer and immediately backs out.
    if (!bodyChanged && !visibilityChanged && !urgentChanged) {
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
      _postAsUrgent = false;
      _isSubmittingComposer = false;
      _isLoadingUrgentEligibility = false;
      _urgentEligibility = null;
      _composerBaselineBody = "";
      _composerBaselineAnonymous = _defaultAnonymousPosting;
      _composerBaselineUrgent = false;
      _selectedTabIndex = nextTabIndex;
    });
  }

  Future<void> _loadUrgentEligibility({String? excludePostId}) async {
    if (_isLoadingUrgentEligibility) {
      return;
    }

    setState(() {
      _isLoadingUrgentEligibility = true;
    });

    try {
      final FeedUrgentEligibility eligibility = await _controller
          .fetchUrgentEligibility(excludePostId: excludePostId);

      if (!mounted) {
        return;
      }

      setState(() {
        _urgentEligibility = eligibility;
        _isLoadingUrgentEligibility = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingUrgentEligibility = false;
      });
      _showNotice(mapFeedErrorMessage(error));
    }
  }

  Future<bool> _ensureUrgentAvailable({String? excludePostId}) async {
    if (_urgentEligibility == null) {
      await _loadUrgentEligibility(excludePostId: excludePostId);
    }

    final FeedUrgentEligibility? eligibility = _urgentEligibility;
    if (eligibility == null) {
      return false;
    }

    if (eligibility.canUseUrgent) {
      return true;
    }

    _showNotice(_urgentUnavailableNotice(eligibility));
    return false;
  }

  bool get _canToggleUrgent {
    if (_postAsUrgent) {
      return true;
    }

    if (_isLoadingUrgentEligibility) {
      return false;
    }

    return _urgentEligibility?.canUseUrgent ?? false;
  }

  String get _urgentHelperText {
    final FeedUrgentEligibility? eligibility = _urgentEligibility;
    if (_isLoadingUrgentEligibility) {
      return "Checking your urgent prayer availability...";
    }

    if (eligibility == null) {
      return "Urgent prayers are limited by a cooldown window.";
    }

    if (eligibility.canUseUrgent) {
      return "Use this for time-sensitive prayer requests. One urgent prayer every ${_formatUrgentCooldown(eligibility.cooldownSeconds)}.";
    }

    return _urgentUnavailableNotice(eligibility);
  }

  String _urgentUnavailableNotice(FeedUrgentEligibility eligibility) {
    final DateTime? nextAvailableAt = eligibility.nextAvailableAt?.toLocal();
    if (nextAvailableAt == null) {
      return "Urgent prayers are limited to one per ${_formatUrgentCooldown(eligibility.cooldownSeconds)}.";
    }

    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String dateLabel = localizations.formatMediumDate(nextAvailableAt);
    final String timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(nextAvailableAt),
    );
    return "Urgent will be available again on $dateLabel at $timeLabel.";
  }

  String _formatUrgentCooldown(int cooldownSeconds) {
    const int secondsPerDay = 24 * 60 * 60;
    const int secondsPerHour = 60 * 60;

    if (cooldownSeconds % secondsPerDay == 0) {
      final int days = cooldownSeconds ~/ secondsPerDay;
      return days == 1 ? "1 day" : "$days days";
    }

    if (cooldownSeconds % secondsPerHour == 0) {
      final int hours = cooldownSeconds ~/ secondsPerHour;
      return hours == 1 ? "1 hour" : "$hours hours";
    }

    if (cooldownSeconds % 60 == 0) {
      final int minutes = cooldownSeconds ~/ 60;
      return minutes == 1 ? "1 minute" : "$minutes minutes";
    }

    return cooldownSeconds == 1 ? "1 second" : "$cooldownSeconds seconds";
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
