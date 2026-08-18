import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_constants.dart';
import '../../models/app_notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../routes/route_names.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/company_initials_avatar.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Catat screen_view untuk GA4 supaya traffic dari app ikut tercatat
    // di Realtime, bukan cuma dari web.
    AnalyticsService.instance.logScreenView(
      screenName: '/notifications',
      screenClass: 'NotificationScreen',
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(notificationFeedProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationFeedProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationFeedState state) {
    if (state.isLoadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(notificationFeedProvider.notifier).loadFirstPage(),
      );
    }

    if (state.items.isEmpty) {
  return ListView(
    controller: _scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: const [
      SizedBox(height: 140),
      EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Belum Ada Notifikasi',
        message:
            'Aktifkan preferensi kota/profesi di Pengaturan supaya\ntidak ketinggalan loker baru.',
      ),
      SizedBox(height: 300),
    ],
  );
}

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return _NotificationTile(notification: state.items[index]);
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotificationModel notification;
  const _NotificationTile({required this.notification});

  /// Ambil nama perusahaan dari body notifikasi, format "Nama — Kota".
  /// Dipakai sebagai fallback avatar inisial saat companyLogo kosong.
  String get _companyName {
    final body = notification.body;
    final sepIndex = body.indexOf('—');
    if (sepIndex == -1) return body;
    return body.substring(0, sepIndex).trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        ref.read(notificationFeedProvider.notifier).markAsRead(notification.id);
        // jobId dijamin tidak null di sini — item tanpa job_id (atau yang
        // lokernya sudah 404) sudah difilter di NotificationFeedNotifier.
        context.pushNamed(
          RouteNames.jobDetail,
          pathParameters: {'id': notification.jobId.toString()},
        );
      },
      child: Container(
        color: notification.isRead ? null : AppColors.primary.withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: notification.companyLogo != null &&
                      notification.companyLogo!.isNotEmpty
                  ? Image.network(
                      notification.companyLogo!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return CompanyInitialsAvatar(name: _companyName, size: 40);
                      },
                    )
                  : CompanyInitialsAvatar(name: _companyName, size: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(notification.body, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notification.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }
}
