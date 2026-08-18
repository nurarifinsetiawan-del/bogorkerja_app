import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/bookmark/bookmark_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/job_detail/job_detail_screen.dart';
import '../screens/main_wrapper/main_wrapper_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'route_names.dart';

/// Root navigator key dipakai untuk push route full-screen (Job Detail,
/// Settings) di ATAS bottom navigation shell, bukan di dalam salah satu
/// tab-nya — supaya bottom nav ikut hilang saat masuk ke halaman itu,
/// sesuai pola app job-portal pada umumnya.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Bottom Navigation Shell — Beranda, Cari, Simpan, Notifikasi, Profil.
      // StatefulShellRoute menjaga state tiap tab (mis. posisi scroll,
      // hasil pencarian) tetap ada saat pindah tab, tidak rebuild dari nol.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.search,
              name: RouteNames.search,
              builder: (context, state) => const SearchScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.bookmark,
              name: RouteNames.bookmark,
              builder: (context, state) => const BookmarkScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.notification,
              name: RouteNames.notification,
              builder: (context, state) => const NotificationScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.profile,
              name: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Route full-screen di luar shell (pakai root navigator supaya
      // bottom nav bar tersembunyi saat halaman ini dibuka).
      GoRoute(
        path: RoutePaths.jobDetail,
        name: RouteNames.jobDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return JobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
