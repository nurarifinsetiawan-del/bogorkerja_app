class HowToApply {
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? link;

  const HowToApply({this.email, this.phone, this.whatsapp, this.link});

  factory HowToApply.fromJson(Map<String, dynamic> json) {
    return HowToApply(
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      link: json['link']?.toString(),
    );
  }

  bool get hasAnyContact =>
      email != null || phone != null || whatsapp != null || link != null;
}

/// Mapping ke `JobDetailResource` — dipakai khusus di layar Detail Lowongan.
class JobDetailModel {
  final int id;
  final String title;
  final String slug;
  final String company;
  final String? logoUrl;
  final String city;
  final String? district;
  final String? address;
  final String? salary;
  final String employmentType;
  final String employmentTypeLabel;
  final List<String> education;
  final bool isRecommended;
  final bool isExpired;
  final int views;
  final DateTime? postedAt;
  final DateTime? expiresAt;
  final String description;
  final String? requirementsHtml;
  final HowToApply howToApply;
  final String shareUrl;

  const JobDetailModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.company,
    this.logoUrl,
    required this.city,
    this.district,
    this.address,
    this.salary,
    required this.employmentType,
    required this.employmentTypeLabel,
    this.education = const [],
    this.isRecommended = false,
    this.isExpired = false,
    this.views = 0,
    this.postedAt,
    this.expiresAt,
    required this.description,
    this.requirementsHtml,
    required this.howToApply,
    required this.shareUrl,
  });

  factory JobDetailModel.fromJson(Map<String, dynamic> json) {
    return JobDetailModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString(),
      address: json['address']?.toString(),
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
      description: json['description']?.toString() ?? '',
      requirementsHtml: json['requirements_html']?.toString(),
      howToApply: HowToApply.fromJson(
        (json['how_to_apply'] as Map<dynamic, dynamic>? ?? {}).cast<String, dynamic>(),
      ),
      shareUrl: json['share_url']?.toString() ?? '',
    );
  }

  /// Konversi ringan ke [JobModel] supaya bisa disimpan sebagai bookmark
  /// tanpa perlu request ulang saat ditampilkan di list Bookmark.
  Map<String, dynamic> toJobCardJson() {
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
