// lib/features/home/widgets/home_slider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_providers.dart';
import '../event/event_detail_page.dart';

const Color kPrimaryColor = Color(0xFF641515);

/// =============================================================
/// DATA ITEM SLIDER + WIDGET SLIDER
/// =============================================================

/// Data untuk satu item di slider home (UI only).
class HomeSliderItemData {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;

  const HomeSliderItemData({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
  });
}

/// Slider/banner di halaman home.
class HomeSlider extends StatefulWidget {
  final List<HomeSliderItemData> items;
  final double height;
  final Duration autoPlayInterval;

  const HomeSlider({
    super.key,
    required this.items,
    this.height = 190,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.items.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted) return;
      int nextPage = _currentIndex + 1;
      if (nextPage >= widget.items.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant HomeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height + 28,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final item = widget.items[index];

                final bool isActive = index == _currentIndex;
                final double scale = isActive ? 1.0 : 0.92;
                final double elevation = isActive ? 10 : 2;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: GestureDetector(
                      onTap: item.onTap,
                      child: Material(
                        elevation: elevation,
                        shadowColor: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Gambar / background
                            if (item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty)
                              Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.black38,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF8E0E00),
                                      Color(0xFF1F1C18),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white70,
                                    size: 45,
                                  ),
                                ),
                              ),

                            // Overlay gradient bawah untuk teks
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.25),
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Badge kecil di pojok
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.bolt_rounded,
                                      size: 14,
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Event Terdekat',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Overlay teks di bawah
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 10, 16, 14),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                      theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    if (item.subtitle != null &&
                                        item.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subtitle!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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
          const SizedBox(height: 10),
          // Indicator modern
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (index) {
              final active = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active ? 20 : 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.25),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// =============================================================
/// SECTION "EVENT TERDEKAT" YANG PAKAI PROVIDER + HomeSlider
/// =============================================================

class HomeSlidersSection extends ConsumerWidget {
  const HomeSlidersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final slidersAsync = ref.watch(homeSliderEventsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Event Terdekat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // TANPA CARD WRAPPER — langsung slider/gambar saja
          slidersAsync.when(
            // LOADING
            loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),

            // ERROR
            error: (err, _) => SizedBox(
              height: 120,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Gagal memuat slider:\n$err',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // DATA
            data: (items) {
              if (items.isEmpty) {
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Belum ada event yang tampil di slider.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final sliderItems = items.map((e) {
                final date = e.dateText ?? '';
                final tempat = e.tempatPelaksanaan ?? '';

                final subtitleParts = <String>[];
                if (date.isNotEmpty) subtitleParts.add(date);
                if (tempat.isNotEmpty) subtitleParts.add(tempat);

                final subtitle = subtitleParts.join(' • ');

                return HomeSliderItemData(
                  title: e.namaEvent,
                  subtitle: subtitle,
                  imageUrl: e.imageUrl, // di model sudah full URL
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(slug: e.slug),
                      ),
                    );
                  },
                );
              }).toList();

              return HomeSlider(
                items: sliderItems,
                height: 190,
              );
            },
          ),
        ],
      ),
    );
  }
}
