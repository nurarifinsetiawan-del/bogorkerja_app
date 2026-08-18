import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/taxonomy_model.dart';
import '../../../repository/job_repository.dart';
import '../../../routes/route_names.dart';
import '../../../theme/app_colors.dart';
import '../home_screen.dart' show searchInitialFilterProvider;

class BannerCarousel extends ConsumerStatefulWidget {
  final List<BannerModel> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BannerModel banner) async {
    switch (banner.actionType) {
      case 'external_url':
        if (banner.actionValue != null) {
          final uri = Uri.tryParse(banner.actionValue!);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      case 'job':
        final id = int.tryParse(banner.actionValue ?? '');
        if (id != null && mounted) {
          context.pushNamed(RouteNames.jobDetail, pathParameters: {'id': id.toString()});
        }
        return;
      case 'profession':
      case 'category':
        if (mounted) {
          ref.read(searchInitialFilterProvider.notifier).state =
              JobFilter(profession: banner.actionValue);
          context.pushNamed(RouteNames.search);
        }
        return;
      case 'city':
        if (mounted) {
          ref.read(searchInitialFilterProvider.notifier).state =
              JobFilter(city: banner.actionValue);
          context.pushNamed(RouteNames.search);
        }
        return;
      default:
        // Belum ada action_type spesifik (atau backend belum isi) —
        // default paling masuk akal: buka daftar lowongan terbaru,
        // supaya banner tetap "bisa diklik" apa pun isinya.
        if (mounted) {
          ref.read(searchInitialFilterProvider.notifier).state =
              const JobFilter(sort: 'latest');
          context.pushNamed(RouteNames.search);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 92,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _handleTap(banner),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Kanvas dasar gradien — selalu tampil, jadi banner
                          // tetap menarik walau tidak ada gambar dari CMS.
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, AppColors.secondary],
                              ),
                            ),
                          ),
                          // Aksen bentuk dekoratif — kesan lebih hidup & premium.
                          Positioned(
                            right: -28,
                            top: -34,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -18,
                            bottom: -30,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          if (banner.imageUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: banner.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, _, __) => const SizedBox.shrink(),
                              placeholder: (context, _) => const SizedBox.shrink(),
                            ),
                          if (banner.imageUrl.isNotEmpty)
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.black38, Colors.transparent],
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    banner.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      height: 1.25,
                                      shadows: [Shadow(blurRadius: 6, color: Colors.black26)],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.banners.length,
            effect: ExpandingDotsEffect(
              dotHeight: 5,
              dotWidth: 5,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ],
    );
  }
}
