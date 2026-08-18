import '../models/job_model.dart';
import '../services/hive_service.dart';

/// Bookmark disimpan 100% lokal (Hive) — tidak sinkron ke server, sesuai
/// keputusan: app ini tidak punya sistem akun untuk pencari kerja.
/// Key box = job id (string), value = JSON job (Map) supaya list Bookmark
/// bisa langsung ditampilkan tanpa request API tambahan.
class BookmarkRepository {
  final _box = HiveService.instance.bookmarksBox;

  bool isBookmarked(int jobId) => _box.containsKey(jobId.toString());

  Future<void> add(JobModel job) async {
    await _box.put(job.id.toString(), job.toJson());
  }

  Future<void> remove(int jobId) async {
    await _box.delete(jobId.toString());
  }

  Future<void> toggle(JobModel job) async {
    if (isBookmarked(job.id)) {
      await remove(job.id);
    } else {
      await add(job);
    }
  }

  List<JobModel> getAll() {
    final jobs = _box.values
        .map((e) => JobModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    // Terbaru disimpan tampil di atas.
    jobs.sort((a, b) => b.id.compareTo(a.id));
    return jobs;
  }

  int get count => _box.length;
}
