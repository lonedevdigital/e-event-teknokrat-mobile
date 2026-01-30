// lib/features/home/event/event_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_providers.dart';
import 'event_detail_page.dart';

// Import ini hanya jika Anda memindahkan kPrimaryColor ke file config global
const Color kPrimaryColor = Color(0xFF641515);

class EventListPage extends ConsumerStatefulWidget {
  const EventListPage({super.key});

  @override
  ConsumerState<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends ConsumerState<EventListPage> {
  final TextEditingController _searchC = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _sortAscending = true;
  bool _showFilter = false;

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(homeEventsProvider);

    // MENGGUNAKAN MATERIAL AGAR INKWELL BERFUNGSI & FIX ERROR "NO MATERIAL FOUND"
    return Material(
      color: Colors.transparent, // Transparan agar mengikuti background PageWrapper
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Gagal memuat event:\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (events) {
          final Set<String> categories = {
            for (final e in events)
              if (e.kategori != null && e.kategori!.isNotEmpty) e.kategori!,
          };

          var filtered = events.where((e) {
            final matchSearch = _searchQuery.isEmpty ||
                e.namaEvent.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchCategory = _selectedCategory == null || (e.kategori == _selectedCategory);
            return matchSearch && matchCategory;
          }).toList();

          filtered.sort((a, b) {
            final da = DateTime.tryParse(a.tanggalPelaksanaan ?? '');
            final db = DateTime.tryParse(b.tanggalPelaksanaan ?? '');
            if (da == null || db == null) return 0;
            return _sortAscending ? da.compareTo(db) : db.compareTo(da);
          });

          return SingleChildScrollView(
            // PADDING BAWAH EXTRA (110) AGAR KONTEN TIDAK TERTUTUP FOOTER MELAYANG
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(theme),
                if (_showFilter) _buildFilterPanel(categories.toList(), theme),
                const SizedBox(height: 20),

                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map((e) => _EventRowSimple(event: e)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Row(
      children: [
        _CustomSmallButton(
          onTap: () => setState(() => _sortAscending = !_sortAscending),
          icon: Icons.swap_vert_rounded,
          label: _sortAscending ? 'Terdekat' : 'Terjauh',
        ),
        const SizedBox(width: 8),
        _CustomSmallButton(
          onTap: () => setState(() => _showFilter = !_showFilter),
          icon: Icons.tune_rounded,
          label: 'Filter',
          isActive: _showFilter,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: _searchC,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari Event...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, size: 20, color: kPrimaryColor),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(List<String> categories, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Filter Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((c) {
              final active = _selectedCategory == c;
              return ChoiceChip(
                label: Text(c),
                selected: active,
                onSelected: (_) => setState(() => _selectedCategory = active ? null : c),
                selectedColor: kPrimaryColor.withOpacity(0.15),
                backgroundColor: Colors.grey.shade50,
                side: BorderSide(color: active ? kPrimaryColor : Colors.grey.shade200),
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: active ? kPrimaryColor : Colors.black54,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Tidak ada event yang cocok.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CustomSmallButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool isActive;

  const _CustomSmallButton({
    required this.onTap,
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? kPrimaryColor : Colors.grey.shade300),
          boxShadow: isActive ? [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black87
                )
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRowSimple extends StatelessWidget {
  final HomeEventData event;
  const _EventRowSimple({required this.event});

  @override
  Widget build(BuildContext context) {
    final statusLower = event.status.toLowerCase();
    final bool isOpen = statusLower == 'dibuka' || statusLower == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(slug: event.slug)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // DEKORASI DOT KATEGORI
                Container(
                  width: 4,
                  height: 30,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.namaEvent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.kategori ?? 'Umum',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event.status.isEmpty ? '-' : event.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOpen ? Colors.green.shade700 : Colors.black45,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}