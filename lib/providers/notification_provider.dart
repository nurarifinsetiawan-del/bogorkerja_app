import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failures.dart';
import '../models/app_notification_model.dart';
import 'core_providers.dart';
import 'settings_provider.dart';

class NotificationFeedState {
  final List<AppNotificationModel> items;
  final bool isLoadingFirstPage;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? errorMessage;

  const NotificationFeedState({
    this.items = const [],
    this.isLoadingFirstPage = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.errorMessage,
  });

  NotificationFeedState copyWith({
    List<AppNotificationModel>? items,
    bool? isLoadingFirstPage,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationFeedState(
      items: items ?? this.items,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get unreadCount => items.where((n) => !n.isRead).length;
}

class NotificationFeedNotifier extends Notifier<NotificationFeedState> {
  /// Batas jumlah notifikasi yang ditampilkan di tab ini. Lebih dari ini,
  /// yang paling lama (di ujung list, karena feed diurutkan terbaru dulu)
  /// otomatis dibuang supaya list tetap ringan.
  static const int _maxItems = 20;

  /// job_id yang sudah dikonfirmasi hilang (404) dari backend — dicek sekali
  /// per id lalu diingat di sesi ini, supaya tidak query berkali-kali tiap
  /// refresh/loadMore untuk id yang sama.
  final Set<int> _confirmedMissingJobIds = {};

  @override
  NotificationFeedState build() {
    Future.microtask(loadFirstPage);
    return const NotificationFeedState(isLoadingFirstPage: true);
  }

  /// Notifikasi tanpa job_id sama sekali (backend tidak mengaitkan loker),
  /// atau job_id yang sudah dikonfirmasi 404, langsung disembunyikan dari
  /// tab Notifikasi — bukan cuma dibuat tidak bisa diklik.
  List<AppNotificationModel> _visible(List<AppNotificationModel> items) {
    return items
        .where((n) => n.jobId != null && !_confirmedMissingJobIds.contains(n.jobId))
        .toList();
  }

  /// Potong ke _maxItems item terbaru. Feed diasumsikan datang dari backend
  /// terurut terbaru → terlama (sama seperti yang tampil di layar), jadi
  /// take() di sini otomatis membuang yang paling lama.
  List<AppNotificationModel> _capped(List<AppNotificationModel> items) {
    return items.length > _maxItems ? items.take(_maxItems).toList() : items;
  }

  /// Cek diam-diam (tanpa nge-block UI) apakah loker di balik tiap
  /// notifikasi masih ada. Kalau backend balas 404, id-nya disimpan dan
  /// notifikasinya langsung dicoret dari state saat ini.
  Future<void> _verifyJobsStillExist(List<AppNotificationModel> items) async {
    final repo = ref.read(jobRepositoryProvider);
    final idsToCheck = items
        .map((n) => n.jobId)
        .whereType<int>()
        .where((id) => !_confirmedMissingJobIds.contains(id))
        .toSet();

    for (final id in idsToCheck) {
      final result = await repo.getJobDetail(id);
      result.when(
        success: (_) {},
        failure: (f) {
          if (f is NotFoundFailure) {
            _confirmedMissingJobIds.add(id);
            state = state.copyWith(
              items: state.items.where((n) => n.jobId != id).toList(),
            );
          }
        },
      );
    }
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoadingFirstPage: true, clearError: true);

    final deviceId = ref.read(settingsProvider).deviceId;
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(deviceId: deviceId, page: 1);

    result.when(
      success: (paginated) {
        final visible = _capped(_visible(paginated.items));
        state = state.copyWith(
          items: visible,
          isLoadingFirstPage: false,
          // Kalau sudah capai batas 20, tidak perlu ambil halaman
          // berikutnya lagi meskipun backend masih punya lebih banyak.
          hasMore: visible.length < _maxItems && paginated.hasMorePages,
          page: 1,
        );
        _verifyJobsStillExist(visible);
      },
      failure: (f) {
        state = state.copyWith(isLoadingFirstPage: false, errorMessage: f.message);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.items.length >= _maxItems) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.page + 1;
    final deviceId = ref.read(settingsProvider).deviceId;
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(deviceId: deviceId, page: nextPage);

    result.when(
      success: (paginated) {
        final visibleNewItems = _visible(paginated.items);
        final combined = _capped([...state.items, ...visibleNewItems]);
        state = state.copyWith(
          items: combined,
          isLoadingMore: false,
          hasMore: combined.length < _maxItems && paginated.hasMorePages,
          page: nextPage,
        );
        _verifyJobsStillExist(visibleNewItems);
      },
      failure: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  Future<void> refresh() => loadFirstPage();

  /// Sama seperti refresh(), tapi tanpa memicu isLoadingFirstPage — dipakai
  /// saat push notification baru masuk sementara tab Notifikasi sedang
  /// dibuka, supaya list ter-update tanpa layar sempat berkedip jadi
  /// full-page loading spinner.
  Future<void> silentRefresh() async {
    final deviceId = ref.read(settingsProvider).deviceId;
    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(deviceId: deviceId, page: 1);

    result.when(
      success: (paginated) {
        final visible = _capped(_visible(paginated.items));
        state = state.copyWith(
          items: visible,
          hasMore: visible.length < _maxItems && paginated.hasMorePages,
          page: 1,
          clearError: true,
        );
        _verifyJobsStillExist(visible);
      },
      failure: (_) {
        // Diam-diam gagal juga tidak apa — list lama tetap ditampilkan,
        // user masih bisa pull-to-refresh manual kalau mau coba lagi.
      },
    );
  }

  Future<void> markAsRead(int notificationId) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.id == notificationId) n.copyWith(isRead: true) else n,
      ],
    );
  }
}

final notificationFeedProvider =
    NotifierProvider<NotificationFeedNotifier, NotificationFeedState>(
  NotificationFeedNotifier.new,
);
