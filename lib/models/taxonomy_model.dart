import '../core/constants/api_constants.dart';
import 'job_model.dart';

/// Dipakai untuk section "Berdasarkan Profesi" & "Berdasarkan Kota" di
/// Home, dan untuk dropdown filter di Search.
class CategoryModel {
  final String slug;
  final String label;
  final int jobCount;
  final List<JobModel> jobs;

  const CategoryModel({
    required this.slug,
    required this.label,
    required this.jobCount,
    this.jobs = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      slug: json['slug']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      jobCount: json['job_count'] as int? ?? 0,
      jobs: (json['jobs'] as List<dynamic>? ?? [])
          .map((e) => JobModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

/// Section "Berdasarkan Perusahaan" di Home & daftar filter perusahaan
/// di Search.
class CompanyModel {
  final String name;
  final String? rawName;
  final String? logoUrl;
  final int jobCount;

  const CompanyModel({
    required this.name,
    this.rawName,
    this.logoUrl,
    required this.jobCount,
  });

  /// Mengubah path logo dari API menjadi URL lengkap yang bisa
  /// digunakan oleh CachedNetworkImage.
  static String? _normalizeLogoUrl(dynamic value) {
    final raw = value?.toString().trim();

    if (raw == null || raw.isEmpty) {
      return null;
    }

    // Data URI, misalnya data:image/png;base64,...
    if (raw.startsWith('data:image')) {
      return raw;
    }

    // URL lengkap sudah benar.
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // Path relatif dari API, misalnya:
    // /uploads/perusahaan.webp
    final path = raw.startsWith('/') ? raw : '/$raw';

    return '${ApiConstants.baseUrl}$path';
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      name: json['name']?.toString() ?? '',
      rawName: json['raw_name']?.toString(),
      logoUrl: _normalizeLogoUrl(json['logo_url']),
      jobCount: json['job_count'] as int? ?? 0,
    );
  }
}

class BannerModel {
  final int id;
  final String imageUrl;
  final String title;
  final String actionType;
  final String? actionValue;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.actionType,
    this.actionValue,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: json['image_url']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      actionType: json['action_type']?.toString() ?? 'external_url',
      actionValue: json['action_value']?.toString(),
    );
  }
}
