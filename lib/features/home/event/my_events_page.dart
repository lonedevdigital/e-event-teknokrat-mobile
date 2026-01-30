// lib/features/home/event/my_events_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'event_providers.dart';
import 'event_detail_page.dart';

const Color kPrimaryColor = Color(0xFF641515);

class MyEventsPage extends ConsumerStatefulWidget {
  const MyEventsPage({super.key});

  @override
  ConsumerState<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends ConsumerState<MyEventsPage> {
  String _searchQuery = '';
  bool _sortAsc = true;
  String _statusFilter = 'all';

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _toggleSort() {
    setState(() => _sortAsc = !_sortAsc);
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _StatusChipData(value: 'all', label: 'Semua'),
                    _StatusChipData(value: 'registered', label: 'Terdaftar'),
                    _StatusChipData(value: 'hadir', label: 'Hadir'),
                  ].map((chip) {
                    final bool selected = _statusFilter == chip.value;
                    return ChoiceChip(
                      label: Text(chip.label),
                      selected: selected,
                      selectedColor: kPrimaryColor.withOpacity(0.12),
                      onSelected: (_) => Navigator.pop(context, chip.value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _statusFilter) {
      setState(() => _statusFilter = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myEventsAsync = ref.watch(myEventsProvider);

    // MENGGUNAKAN MATERIAL SEBAGAI ROOT (BUKAN SCAFFOLD)
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildActionSearchBer(),
          const SizedBox(height: 16),
          Expanded(
            child: myEventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat data: $err')),
              data: (events) {
                var list = events.where((e) {
                  final matchSearch = _searchQuery.isEmpty ||
                      e.namaEvent.toLowerCase().contains(_searchQuery.toLowerCase());

                  if (!matchSearch) return false;

                  if (_statusFilter == 'registered') return !e.sudahHadir;
                  if (_statusFilter == 'hadir') return e.sudahHadir;
                  return true;
                }).toList();

                list.sort((a, b) {
                  int cmp = a.tanggal.compareTo(b.tanggal);
                  return _sortAsc ? cmp : -cmp;
                });

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EVENT YANG DIIKUTI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 14,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (list.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Belum ada event yang cocok.'),
                        ))
                      else
                        _MyEventsTable(events: list),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSearchBer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SmallButton(
            onPressed: _toggleSort,
            icon: Icons.swap_vert_rounded,
            label: 'Sort',
          ),
          const SizedBox(width: 8),
          _SmallButton(
            onPressed: _openFilterSheet,
            icon: Icons.filter_list_rounded,
            label: 'Filter',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Cari Event...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _SmallButton({required this.onPressed, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 16, color: Colors.black87),
        label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ),
    );
  }
}

class _MyEventsTable extends StatelessWidget {
  final List<MyEventData> events;
  const _MyEventsTable({required this.events});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: const [
                SizedBox(width: 100, child: Text('Event', style: headerStyle)),
                Expanded(child: Text('Pelaksanaan', style: headerStyle)),
                SizedBox(width: 50, child: Text('Hadir', style: headerStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...events.map((e) => _MyEventRow(event: e)).toList(),
        ],
      ),
    );
  }
}

class _MyEventRow extends StatelessWidget {
  final MyEventData event;
  const _MyEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailPage(slug: event.slug)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      event.namaEvent,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      event.pelaksanaanLabel,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Icon(
                      event.sudahHadir ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: event.sudahHadir ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
          ],
        ),
      ),
    );
  }
}

class _StatusChipData {
  final String value;
  final String label;
  _StatusChipData({required this.value, required this.label});
}