import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/bookmark_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/analytics_service.dart';

/// Path GA4 (meniru pola URL di web) untuk tiap tab bottom navigation,
/// dipakai supaya berpindah tab tercatat sebagai screen_view baru —
/// beda dengan tab yang cuma di-cache lewat IndexedStack dan initState-nya
/// tidak terpanggil ulang saat kembali dikunjungi.
const _tabScreenNames = [
  '/',
  '/all-jobs',
  '/bookmarks',
  '/notifications',
  '/profile',
];

/// Wrapper bottom navigation untuk 5 tab utama: Beranda, Cari, Simpan,
/// Notifikasi, Profil. Memakai [StatefulNavigationShell] dari go_router
/// supaya state tiap tab (scroll position, dll) tetap terjaga saat
/// berpindah tab (IndexedStack di baliknya, bukan Navigator.push).
class MainWrapperScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkCount = ref.watch(bookmarkProvider).length;
    final unreadCount = ref.watch(notificationFeedProvider).unreadCount;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // Tap ulang tab yang sedang aktif akan reset ke root tab itu
            // (mis. scroll ke atas), konsisten dengan pola app modern.
            initialLocation: index == navigationShell.currentIndex,
          );

          // Tab di dalam IndexedStack tetap "hidup" setelah kunjungan
          // pertama, jadi initState layar tidak terpanggil ulang saat
          // user bolak-balik tab. Catat screen_view di sini supaya GA4
          // Realtime tetap menunjukkan tab yang sedang aktif dilihat.
          if (index >= 0 && index < _tabScreenNames.length) {
            AnalyticsService.instance.logScreenView(
              screenName: _tabScreenNames[index],
            );
          }
        },
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              icon: Icons.bookmark_border_rounded,
              count: bookmarkCount,
            ),
            selectedIcon: _BadgeIcon(
              icon: Icons.bookmark_rounded,
              count: bookmarkCount,
            ),
            label: 'Simpan',
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              icon: Icons.notifications_outlined,
              count: unreadCount,
            ),
            selectedIcon: _BadgeIcon(
              icon: Icons.notifications_rounded,
              count: unreadCount,
            ),
            label: 'Notifikasi',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgeIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);

    return Badge(
      label: Text(count > 9 ? '9+' : '$count'),
      child: Icon(icon),
    );
  }
}
