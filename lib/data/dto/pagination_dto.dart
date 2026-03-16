class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        page: (json['page'] as num).toInt(),
        limit: (json['limit'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
        hasNextPage: json['hasNextPage'] as bool,
        hasPreviousPage: json['hasPreviousPage'] as bool,
      );
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({required this.data, required this.meta});
}
