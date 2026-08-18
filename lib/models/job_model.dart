import '../core/constants/api_constants.dart';
/// Model lowongan versi ringkas — mapping 1:1 ke `JobResource` di backend
/// Laravel (lihat app/Http/Resources/JobResource.php). Dipakai di semua
/// list/card: Home, Search, Bookmark.
class JobModel {
  final int id;
  final String title;
  final String slug;
  final String company;
  final String? logoUrl;
  final String city;
  final String? district;
  final String? salary;
  final String employmentType;
  final String employmentTypeLabel;
  final List<String> education;
  final bool isRecommended;
  final bool isExpired;
  final int views;
  final DateTime? postedAt;
  final DateTime? expiresAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.company,
    this.logoUrl,
    required this.city,
    this.district,
    this.salary,
    required this.employmentType,
    required this.employmentTypeLabel,
    this.education = const [],
    this.isRecommended = false,
    this.isExpired = false,
    this.views = 0,
    this.postedAt,
    this.expiresAt,
  });

static String? _resolveImageUrl(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final url = value.trim();

  // Sudah URL lengkap
  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    return url;
  }

  // URL relatif seperti /uploads/logo.webp
  return Uri.parse(ApiConstants.baseUrl).resolve(url).toString();
}

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      logoUrl: _resolveImageUrl(json['logo_url']?.toString()),
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString(),
      salary: json['salary']?.toString(),
      employmentType: json['employment_type']?.toString() ?? 'FULL_TIME',
      employmentTypeLabel: json['employment_type_label']?.toString() ?? '',
      education: (json['education'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isRecommended: json['is_recommended'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      postedAt: json['posted_at'] != null ? DateTime.tryParse(json['posted_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'company': company,
      'logo_url': logoUrl,
      'city': city,
      'district': district,
      'salary': salary,
      'employment_type': employmentType,
      'employment_type_label': employmentTypeLabel,
      'education': education,
      'is_recommended': isRecommended,
      'is_expired': isExpired,
      'views': views,
      'posted_at': postedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
