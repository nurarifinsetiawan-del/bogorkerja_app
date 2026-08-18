import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/bookmark_provider.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/screen_view_logger.dart';
import '../../widgets/job/job_card.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);

    return ScreenViewLogger(
      screenName: '/bookmarks',
      screenClass: 'BookmarkScreen',
      child: Scaffold(
      appBar: AppBar(
        title: Text('Loker Tersimpan (${bookmarks.length})'),
        automaticallyImplyLeading: false,
      ),
      body: bookmarks.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Belum Ada Loker Tersimpan',
              message: 'Simpan lowongan yang menarik supaya mudah ditemukan lagi nanti.',
              action: FilledButton(
                onPressed: () => context.goNamed(RouteNames.search),
                child: const Text('Cari Lowongan'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Dismissible(
                key: ValueKey(bookmarks[index].id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => ref.read(bookmarkProvider.notifier).remove(bookmarks[index].id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                child: JobCard(job: bookmarks[index]),
              ),
            ),
      ),
    );
  }
}
