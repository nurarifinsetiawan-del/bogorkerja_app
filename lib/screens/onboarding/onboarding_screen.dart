import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/taxonomy_provider.dart';
import '../../routes/route_names.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../theme/app_colors.dart';

/// Ditampilkan HANYA sekali (dicek lewat [AppConstants.keyOnboardingSeen]
/// di Hive) — biarkan user memilih minat kota & profesi supaya notifikasi
/// loker baru yang diterima lebih relevan sejak awal (opsional, bisa
/// dilewati & diubah lagi nanti dari Settings).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _selectedCity;
  String? _selectedProfession;

  @override
  void initState() {
    super.initState();

    // Catat screen_view untuk GA4 supaya traffic dari app ikut tercatat
    // di Realtime, bukan cuma dari web.
    AnalyticsService.instance.logScreenView(
      screenName: '/onboarding',
      screenClass: 'OnboardingScreen',
    );
  }

  Future<void> _finish(BuildContext context) async {
    if (_selectedCity != null) {
      await ref.read(settingsProvider.notifier).updateCityInterest(_selectedCity);
    }
    if (_selectedProfession != null) {
      await ref.read(settingsProvider.notifier).updateProfessionInterest(_selectedProfession);
    }
    await HiveService.instance.settingsBox.put(AppConstants.keyOnboardingSeen, true);

    if (!context.mounted) return;
    context.goNamed(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    final professionsAsync = ref.watch(professionsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text('Sesuaikan Minat Anda', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih kota & profesi favorit supaya notifikasi loker baru yang Anda terima lebih relevan. Bisa diubah kapan saja lewat Pengaturan.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                children: [
                  Text('Kota Pilihan', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  citiesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Gagal memuat data kota'),
                    data: (cities) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cities.map((c) {
                        final selected = _selectedCity == c.label;
                        return ChoiceChip(
                          label: Text(c.label),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _selectedCity = selected ? null : c.label;
                          }),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Profesi Pilihan', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  professionsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Gagal memuat data profesi'),
                    data: (professions) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: professions.map((p) {
                        final selected = _selectedProfession == p.slug;
                        return ChoiceChip(
                          label: Text(p.label),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _selectedProfession = selected ? null : p.slug;
                          }),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _finish(context),
                      child: const Text('Mulai Cari Kerja'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _finish(context),
                    child: const Text('Lewati'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
