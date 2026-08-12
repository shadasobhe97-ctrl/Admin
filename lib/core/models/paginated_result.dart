import 'pagination_meta_model.dart';

/// غلاف عام لأي قائمة مُصفّحة قادمة من الخادم.
/// يعيد استخدام [PaginationMetaModel] الموجود في المشروع بدل تكراره.
class PaginatedResult<T> {
  final List<T> items;
  final PaginationMetaModel meta;

  const PaginatedResult({
    required this.items,
    required this.meta,
  });

  const PaginatedResult.empty()
      : items = const [],
        meta = const PaginationMetaModel();

  bool get isEmpty => items.isEmpty;
  bool get hasMore => meta.hasMore;

  PaginatedResult<T> copyWith({
    List<T>? items,
    PaginationMetaModel? meta,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      meta: meta ?? this.meta,
    );
  }
}
