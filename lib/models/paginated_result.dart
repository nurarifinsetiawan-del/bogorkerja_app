/// Wrapper generic untuk response paginated Laravel (`data` + `meta`).
/// Dipakai oleh JobRepository.getJobs() & NotificationRepository.getNotifications().
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final bool hasMorePages;
  final int total;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.hasMorePages,
    this.total = 0,
  });

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    return PaginatedResult(
      items: (json['data'] as List<dynamic>? ?? [])
          .map((e) => itemParser((e as Map).cast<String, dynamic>()))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      hasMorePages: meta['has_more_pages'] as bool? ?? false,
      total: meta['total'] as int? ?? 0,
    );
  }
}
