// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_providers.dart';
import 'widgets/home_slider.dart';
import 'widgets/home_event_list.dart';
import 'widgets/home_dok_list.dart';
import 'event/event_detail_page.dart';
import '../../core/widgets/header.dart';

const Color kPrimaryColor = Color(0xFF641515);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _eventSearchC = TextEditingController();
  String _eventSearchQuery = '';

  final TextEditingController _dokSearchC = TextEditingController();
  String _dokSearchQuery = '';

  @override
  void dispose() {
    _eventSearchC.dispose();
    _dokSearchC.dispose();
    super.dispose();
  }

  void _onEventSearchChanged(String value) {
    setState(() => _eventSearchQuery = value);
  }

  void _onDokSearchChanged(String value) {
    setState(() => _dokSearchQuery = value);
  }

  /// FUNGSI REFRESH DATA
  Future<void> _onRefresh() async {
    // Memaksa semua provider home untuk mengambil data baru dari API
    ref.invalidate(homeEventsProvider);
    ref.invalidate(homeSliderEventsProvider);
    ref.invalidate(homeDocumentationProvider);

    // Menunggu salah satu data selesai dimuat agar indikator loading tidak hilang terlalu cepat
    await ref.read(homeEventsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(homeEventsProvider);
    final docsAsync = ref.watch(homeDocumentationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const MainHeader(),

      // FITUR PULL TO REFRESH
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: kPrimaryColor, // Warna indikator loading
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          // BouncingScrollPhysics membuat efek geser lebih terasa di iOS & Android
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeSlidersSection(),
              const SizedBox(height: 24),

              _buildSectionTitle(theme, 'DAFTAR EVENT'),
              const SizedBox(height: 8),

              eventsAsync.when(
                loading: () => const _LoadingIndicator(),
                error: (err, _) => _ErrorText(message: err.toString()),
                data: (events) {
                  final filtered = events.where((e) {
                    if (_eventSearchQuery.isEmpty) return true;
                    return e.namaEvent.toLowerCase().contains(_eventSearchQuery.toLowerCase());
                  }).toList();

                  final uiEvents = filtered.map((e) => HomeEventItemData(
                    id: e.id.toString(),
                    title: e.namaEvent,
                    dateText: e.dateText,
                    location: e.tempatPelaksanaan,
                    description: e.deskripsi,
                    imageUrl: e.imageUrl,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventDetailPage(slug: e.slug)),
                    ),
                  )).toList();

                  return HomeEventList(
                    events: uiEvents,
                    searchController: _eventSearchC,
                    onSearchChanged: _onEventSearchChanged,
                  );
                },
              ),

              const SizedBox(height: 32),

              _buildSectionTitle(theme, 'DOKUMENTASI'),
              const SizedBox(height: 8),

              docsAsync.when(
                loading: () => const _LoadingIndicator(),
                error: (err, _) => _ErrorText(message: err.toString()),
                data: (docs) {
                  final filtered = docs.where((d) {
                    if (_dokSearchQuery.isEmpty) return true;
                    return d.namaEvent.toLowerCase().contains(_dokSearchQuery.toLowerCase());
                  }).toList();

                  final uiItems = filtered.map((d) => HomeDokItemData(
                    id: d.id.toString(),
                    title: d.namaEvent,
                    dateText: d.dateText,
                    imageUrl: d.imageUrl,
                    onTap: () {
                      // Implementasi detail dokumentasi
                    },
                  )).toList();

                  return HomeDokList(
                    items: uiItems,
                    searchController: _dokSearchC,
                    onSearchChanged: _onDokSearchChanged,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: Text(
        'Gagal memuat data:\n$message',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    ),
  );
}