import 'package:flutter/material.dart';

import '../../../../core/utils/admin_theme_context.dart';
import '../../data/models/geography_type.dart';

/// شريط بحث تفاعلي مع فلتر النوع يوضع داخل شاشة إدارة المناطق الجغرافية.
class GeographySearchBar extends StatefulWidget {
  final GeographyType currentType;
  final ValueChanged<GeographyType> onTypeChanged;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final TextEditingController? controller;

  const GeographySearchBar({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
    required this.onChanged,
    required this.onClear,
    this.controller,
  });

  @override
  State<GeographySearchBar> createState() => _GeographySearchBarState();
}

class _GeographySearchBarState extends State<GeographySearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasTextNow = _controller.text.trim().isNotEmpty;
    if (hasTextNow != _hasText) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Row(
        children: [
          // فلتر نوع البحث (البلدية الكبرى / البلدية الفرعية / المنطقة)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderSoft),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GeographyType>(
                value: widget.currentType,
                icon: Icon(Icons.arrow_drop_down_rounded,
                    color: context.textPrimary),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(
                    value: GeographyType.municipality,
                    child: Text('البلدية'),
                  ),
                  DropdownMenuItem(
                    value: GeographyType.subMunicipality,
                    child: Text('البلدية الفرعية'),
                  ),
                  DropdownMenuItem(
                    value: GeographyType.region,
                    child: Text('المنطقة'),
                  ),
                ],
                onChanged: (newType) {
                  if (newType != null) {
                    widget.onTypeChanged(newType);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // حقل إدخال كلمة البحث
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: 13.5,
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.currentType.searchHint,
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: context.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.primaryColor,
                  size: 20,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        tooltip: 'مسح البحث',
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: _clear,
                      )
                    : null,
                filled: true,
                fillColor: context.cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderSoft),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderSoft),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
