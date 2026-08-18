import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/core_providers.dart';
import '../../providers/fcm_token_provider.dart';
import '../../providers/settings_provider.dart';
import '../../routes/route_names.dart';
import '../../services/hive_service.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    AnalyticsService.instance.logScreenView(
      screenName: '/splash',
      screenClass: 'SplashScreen',
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Registrasi device untuk push notification berjalan di background,
    // TIDAK memblokir splash (kalau gagal/offline, app tetap bisa dipakai
    // — device akan coba register lagi nanti dari Settings).
    unawaited(_registerDeviceForPush());

    // Splash minimal 1200ms supaya animasi logo terlihat, tapi tidak
    // dibuat berlama-lama menahan user (bukan splash "gimmick").
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final onboardingSeen =
        HiveService.instance.settingsBox.get(AppConstants.keyOnboardingSeen) as bool? ?? false;

    context.goNamed(onboardingSeen ? RouteNames.home : RouteNames.onboarding);
  }

  Future<void> _registerDeviceForPush() async {
    try {
      final token = await ref.read(fcmTokenProvider.future);
      if (token == null) return;

      final settings = ref.read(settingsProvider);
      await ref.read(deviceRepositoryProvider).registerDevice(
            deviceId: settings.deviceId,
            fcmToken: token,
            platform: 'android',
            cityInterest: settings.cityInterest,
            professionInterest: settings.professionInterest,
            notificationsEnabled: settings.notificationsEnabled,
          );
    } catch (_) {
      // Silent fail — bukan alur kritikal untuk splash.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/splash_logo.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cari kerja jadi lebih mudah',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
