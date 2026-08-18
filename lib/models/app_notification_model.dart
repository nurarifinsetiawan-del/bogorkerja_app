class AppNotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final int? jobId;
  final DateTime createdAt;
  final bool isRead;
  final String? companyLogo;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.jobId,
    this.companyLogo,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json, {bool isRead = false}) {
    return AppNotificationModel(
      id: json['id'] as int,
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      jobId: json['job_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      companyLogo: json['company_logo']?.toString(),
      isRead: isRead,
    );
  }

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      jobId: jobId,
      companyLogo: companyLogo,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
