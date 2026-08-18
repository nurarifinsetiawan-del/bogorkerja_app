import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/bookmark_provider.dart';
import '../../routes/route_names.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/screen_view_logger.dart';

/// App ini tidak punya sistem akun job seeker (lihat catatan arsitektur
/// di README backend) — jadi ProfileScreen berfungsi sebagai halaman
/// info app + pintasan, bukan halaman edit profil pengguna.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkCount = ref.watch(bookmarkProvider).length;

    return ScreenViewLogger(
      screenName: '/profile',
      screenClass: 'ProfileScreen',
      child: Scaffold(
      appBar: AppBar(title: const Text('Profil'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
  children: [
    CircleAvatar(
      radius: 28,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.asset(
          'assets/icon/splash_logo.png',
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
    ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cari kerja jadi lebih mudah',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _StatsRow(bookmarkCount: bookmarkCount),
          const SizedBox(height: 20),
          _MenuSection(
            title: 'Preferensi',
            items: [
              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Pengaturan',
                onTap: () => context.pushNamed(RouteNames.settings),
              ),
              _MenuItem(
                icon: Icons.bookmark_border_rounded,
                label: 'Loker Tersimpan',
                onTap: () => context.goNamed(RouteNames.bookmark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuSection(
            title: 'Lainnya',
            items: [
              _MenuItem(
                icon: Icons.language_rounded,
                label: 'Kunjungi Website',
                onTap: () => launchUrl(
                  Uri.parse(ApiConstants.baseUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _MenuItem(
  icon: Icons.share_outlined,
  label: 'Bagikan Aplikasi',
  onTap: () async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Bogor Kerja - Cari lowongan kerja terbaru di Bogor dan sekitarnya.\n\n'
            'Temukan lowongan kerja terbaru melalui aplikasi Bogor Kerja.\n\n'
            '${ApiConstants.baseUrl}',
      ),
    );
  },
),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                label: 'Tentang Aplikasi',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: 'v${info.version} (${info.buildNumber})',
      applicationIcon: const Icon(Icons.work_rounded, color: AppColors.primary, size: 40),
      children: const [
        SizedBox(height: 12),
        Text('Aplikasi pencarian lowongan kerja di wilayah Bogor dan sekitarnya.'),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int bookmarkCount;
  const _StatsRow({required this.bookmarkCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(icon: Icons.bookmark_rounded, label: 'Tersimpan', value: '$bookmarkCount'),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(icon: Icons.visibility_outlined, label: 'Status', value: 'Aktif'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: Icon(items[i].icon, color: AppColors.primary),
                  title: Text(items[i].label),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: items[i].onTap,
                ),
                if (i != items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}
