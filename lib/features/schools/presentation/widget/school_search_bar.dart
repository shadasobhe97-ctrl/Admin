import 'package:flutter/material.dart';

class SchoolSearchBar extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const SchoolSearchBar({
    super.key,
    this.initialQuery,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<SchoolSearchBar> createState() => _SchoolSearchBarState();
}

class _SchoolSearchBarState extends State<SchoolSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant SchoolSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _controller.text = widget.initialQuery ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyLarge,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          widget.onSearch(query.trim());
        },
        decoration: InputDecoration(
          hintText: 'ابحث باسم المدرسة أو العنوان...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
