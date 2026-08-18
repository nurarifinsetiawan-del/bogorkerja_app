import '../core/constants/app_constants.dart';
import '../services/hive_service.dart';

/// Riwayat pencarian disimpan lokal saja — daftar keyword text sederhana,
/// terbaru di depan, dibatasi [AppConstants.recentSearchLimit].
class RecentSearchRepository {
  final _box = HiveService.instance.recentSearchesBox;
  static const _key = 'items';

  List<String> getAll() {
    final raw = _box.get(_key) as List<dynamic>? ?? [];
    return raw.map((e) => e.toString()).toList();
  }

  Future<void> add(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    final items = getAll()..removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    items.insert(0, trimmed);

    if (items.length > AppConstants.recentSearchLimit) {
      items.removeRange(AppConstants.recentSearchLimit, items.length);
    }

    await _box.put(_key, items);
  }

  Future<void> clear() async {
    await _box.delete(_key);
  }
}
