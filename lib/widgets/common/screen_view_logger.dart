import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';

/// Widget tak-terlihat yang mencatat GA4 `screen_view` sekali saat halaman
/// ini pertama kali muncul di pohon widget.
///
/// Dipakai untuk membungkus body tiap screen supaya traffic dari aplikasi
/// ikut tercatat di GA Realtime, tidak hanya traffic dari web. `screenName`
/// sengaja dibuat meniru path di website (mis. "/", "/all-jobs") supaya
/// muncul rapi berdampingan dengan data web di laporan "Halaman dan
/// kelompok tampilan".
class ScreenViewLogger extends StatefulWidget {
  final String screenName;
  final String? screenClass;
  final Widget child;

  const ScreenViewLogger({
    super.key,
    required this.screenName,
    this.screenClass,
    required this.child,
  });

  @override
  State<ScreenViewLogger> createState() => _ScreenViewLoggerState();
}

class _ScreenViewLoggerState extends State<ScreenViewLogger> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(
      screenName: widget.screenName,
      screenClass: widget.screenClass,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
