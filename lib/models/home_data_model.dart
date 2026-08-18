import 'job_model.dart';
import 'taxonomy_model.dart';

/// Mapping ke response gabungan `GET /api/v1/home` — satu model untuk
/// seluruh section di layar Beranda.
class HomeDataModel {
  final List<BannerModel> banners;
  final List<JobModel> latestJobs;
  final List<JobModel> popularJobs;
  final List<CategoryModel> byProfession;
  final List<CategoryModel> byCity;
  final List<CompanyModel> byCompany;

  const HomeDataModel({
    this.banners = const [],
    this.latestJobs = const [],
    this.popularJobs = const [],
    this.byProfession = const [],
    this.byCity = const [],
    this.byCompany = const [],
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    List<T> listOf<T>(String key, T Function(Map<String, dynamic>) parser) {
      return (json[key] as List<dynamic>? ?? [])
          .map((e) => parser((e as Map).cast<String, dynamic>()))
          .toList();
    }

    return HomeDataModel(
      banners: listOf('banners', BannerModel.fromJson),
      latestJobs: listOf('latest_jobs', JobModel.fromJson),
      popularJobs: listOf('popular_jobs', JobModel.fromJson),
      byProfession: listOf('by_profession', CategoryModel.fromJson),
      byCity: listOf('by_city', CategoryModel.fromJson),
      byCompany: listOf('by_company', CompanyModel.fromJson),
    );
  }

  bool get isEmpty =>
      latestJobs.isEmpty && popularJobs.isEmpty && byProfession.isEmpty;
}
