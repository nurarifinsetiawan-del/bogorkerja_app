import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../repository/bookmark_repository.dart';
import '../repository/device_repository.dart';
import '../repository/home_repository.dart';
import '../repository/job_repository.dart';
import '../repository/notification_repository.dart';
import '../repository/recent_search_repository.dart';
import '../repository/taxonomy_repository.dart';

/// Semua dependency "global" di-provide dari satu file ini supaya mudah
/// ditelusuri. Riverpod otomatis membuat instance sekali (lazy singleton)
/// dan membagikannya ke seluruh widget tree.
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final jobRepositoryProvider = Provider<JobRepository>(
  (ref) => JobRepository(ref.watch(dioClientProvider)),
);

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(ref.watch(dioClientProvider)),
);

final taxonomyRepositoryProvider = Provider<TaxonomyRepository>(
  (ref) => TaxonomyRepository(ref.watch(dioClientProvider)),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(dioClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(dioClientProvider)),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) => BookmarkRepository(),
);

final recentSearchRepositoryProvider = Provider<RecentSearchRepository>(
  (ref) => RecentSearchRepository(),
);
