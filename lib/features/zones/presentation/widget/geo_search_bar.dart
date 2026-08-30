import 'package:flutter/material.dart';
import '../../../../core/utils/admin_theme_context.dart';

class GeoSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String initialQuery;
  final String hintText;

  const GeoSearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
    this.initialQuery = '',
    this.hintText = 'ابحث عن بلدية كبرى، محلة (بلدية فرعية)، أو منطقة دقيقة...',
  });

  @override
  State<GeoSearchBar> createState() => _GeoSearchBarState();
}

class _GeoSearchBarState extends State<GeoSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant GeoSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontSize: 13,
          color: context.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 12,
            color: context.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: context.primaryColor,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: context.textTertiary,
                  ),
                  onPressed: _handleClear,
                  tooltip: 'مسح البحث',
                )
              : null,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
