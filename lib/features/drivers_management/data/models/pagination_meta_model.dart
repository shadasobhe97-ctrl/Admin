class PaginationMetaModel {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const PaginationMetaModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 15,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaginationMetaModel();
    return PaginationMetaModel(
      currentPage: json['current_page'] is int ? json['current_page'] : (int.tryParse(json['current_page']?.toString() ?? '1') ?? 1),
      lastPage: json['last_page'] is int ? json['last_page'] : (int.tryParse(json['last_page']?.toString() ?? '1') ?? 1),
      total: json['total'] is int ? json['total'] : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      perPage: json['per_page'] is int ? json['per_page'] : (int.tryParse(json['per_page']?.toString() ?? '15') ?? 15),
    );
  }

  bool get hasMore => currentPage < lastPage;
}
