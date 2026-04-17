import "package:flutter/material.dart";

import "../../design/editorial_tokens.dart";
import "../../localization/app_strings.dart";
import "../shared/language_toggle.dart";

class FeedTopBar extends StatelessWidget {
  const FeedTopBar({
    super.key,
    required this.onMenuTap,
    required this.onSearchTap,
    this.isSearchMode = false,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.onSearchClose,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final bool isSearchMode;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = context.strings;

    if (isSearchMode) {
      final TextEditingController controller = searchController!;

      return SizedBox(
        height: 52,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (
            BuildContext context,
            TextEditingValue value,
            Widget? child,
          ) {
            final bool hasQuery = value.text.trim().isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: EditorialColors.surfaceLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: EditorialColors.outlineVariant.withValues(
                    alpha: hasQuery ? 0.38 : 0.22,
                  ),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0F2D3435),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: EditorialColors.onSurfaceMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: strings.feedSearchPlaceholder,
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.2,
                          color: EditorialColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: EditorialColors.onSurfaceMuted,
                      onPressed: () {
                        if (hasQuery) {
                          controller.clear();
                          onSearchChanged?.call("");
                        }
                        onSearchClose?.call();
                      },
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Text(
              strings.feedTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: EditorialColors.onSurface,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.search, size: 20),
              color: EditorialColors.primary,
              onPressed: onSearchTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const LanguageToggle(compact: true),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  color: EditorialColors.primary,
                  onPressed: onMenuTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
