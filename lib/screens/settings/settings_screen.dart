import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/settings_provider.dart';
import '../../providers/taxonomy_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/screen_view_logger.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final professionsAsync = ref.watch(professionsProvider);
    final citiesAsync = ref.watch(notificationCitiesProvider);

    return ScreenViewLogger(
      screenName: '/settings',
      screenClass: 'SettingsScreen',
      child: Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Tampilan'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Ikuti Sistem'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                RadioListTile<ThemeMode>(
                  title: const Text('Terang'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                RadioListTile<ThemeMode>(
                  title: const Text('Gelap'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Notifikasi'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifikasi Loker Baru'),
                  subtitle: const Text('Dapatkan info loker baru sesuai minat Anda'),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).setNotificationsEnabled(v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Minat Kota'),
          Text(
            'Prioritaskan notifikasi loker dari kota pilihan Anda. Kosongkan untuk menerima dari semua kota.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          citiesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (cities) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cities.map((c) {
                final selected = settings.cityInterest == c.label;
                return ChoiceChip(
                  label: Text(c.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(settingsProvider.notifier)
                      .updateCityInterest(selected ? null : c.label),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Minat Profesi'),
          Text(
            'Prioritaskan notifikasi loker sesuai bidang profesi Anda.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          professionsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (professions) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: professions.map((p) {
                final selected = settings.professionInterest == p.slug;
                return ChoiceChip(
                  label: Text(p.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(settingsProvider.notifier)
                      .updateProfessionInterest(selected ? null : p.slug),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

      _SectionLabel('Tentang'),
      Card(
        child: ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Kebijakan Privasi'),
          subtitle: const Text(
            'Lihat kebijakan privasi Bogor Kerja',
          ),
          trailing: const Icon(
            Icons.open_in_new,
            size: 20,
          ),
          onTap: () => _openPrivacyPolicy(context),
        ),
      ),

      const SizedBox(height: 24),

          
        ],
      ),
      ),
    );
  }
}

/// Buka link Kebijakan Privasi di browser luar.
///
/// SEBELUMNYA tombol ini memakai `canLaunchUrl()` sebagai gerbang sebelum
/// `launchUrl()`. Di Android 11+ (targetSdk 30+), `canLaunchUrl()` untuk
/// skema https/http akan selalu bernilai `false` kalau `AndroidManifest.xml`
/// belum mendeklarasikan `<queries>` untuk intent VIEW — akibatnya tombol
/// terlihat diam saja saat ditekan. Perbaikan di sini ada dua bagian:
/// 1) `AndroidManifest.xml` sudah ditambah `<queries>` untuk https/http.
/// 2) Kode ini langsung memanggil `launchUrl()` (tanpa gerbang
///    `canLaunchUrl` yang rapuh) dan menangkap error supaya user tetap
///    mendapat info jelas kalau link gagal dibuka (mis. tidak ada browser).
Future<void> _openPrivacyPolicy(BuildContext context) async {
  final uri = Uri.parse('https://bogorkerja.id/privacy-policy');

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka kebijakan privasi.'),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka kebijakan privasi.'),
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
