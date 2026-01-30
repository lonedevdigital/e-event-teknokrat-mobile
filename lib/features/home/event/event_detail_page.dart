// lib/features/home/event/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_client.dart';
import '../../../core/widgets/header.dart';
import '../../../core/widgets/footer.dart';
import '../../../core/providers/nav_provider.dart';
import 'event_providers.dart';

const Color kPrimaryColor = Color(0xFF641515);

class EventDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const EventDetailPage({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  bool _isRegistering = false;

  void _handleNav(int index) {
    ref.read(navIndexProvider.notifier).state = index;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _registerEvent() async {
    if (_isRegistering) return;
    setState(() => _isRegistering = true);
    final api = ref.read(apiClientProvider);

    try {
      final res = await api.post('/api/events/${widget.slug}/register');
      final body = res.data as Map<String, dynamic>?;

      if (body != null && body['status'] == true) {
        final msg = body['message']?.toString() ?? 'Berhasil mendaftar event.';
        if (!mounted) return;
        await _showSuccessDialog(context, msg);
      } else {
        final msg = body?['message']?.toString() ?? 'Gagal mendaftar event.';
        if (!mounted) return;
        _showErrorSnack(context, msg);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Berhasil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Selesai', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(eventDetailProvider(widget.slug));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      extendBody: true,
      appBar: const MainHeader(),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (detail) {
          final deskripsiLines = _splitLines(detail.deskripsi);
          final infoLines = _splitLines(detail.informasiLainnya);

          return SingleChildScrollView(
            // Padding bawah ditingkatkan agar area deskripsi bisa di-scroll sampai tuntas
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderDetail(detail, theme),
                const SizedBox(height: 20),
                _buildInfoCards(detail),
                const SizedBox(height: 24),
                _buildSection('Deskripsi', deskripsiLines),
                const SizedBox(height: 20),
                _buildSection('Informasi Lainnya', infoLines),
              ],
            ),
          );
        },
      ),

      // POSISI TOMBOL LEBIH RENDAH (MENDEKATI FOOTER)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: detailAsync.maybeWhen(
        data: (detail) {
          final isOpen = detail.status.toLowerCase() == 'dibuka';
          return Padding(
            // Bottom dikurangi dari 90 menjadi 75 agar lebih "turun"
            padding: const EdgeInsets.only(bottom: 0, right: 8),
            child: FloatingActionButton.extended(
              elevation: 4,
              onPressed: (!isOpen || _isRegistering) ? null : _registerEvent,
              backgroundColor: isOpen ? kPrimaryColor : Colors.grey,
              // Ukuran Ringkas
              label: _isRegistering
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text(
                isOpen ? 'Daftar Sekarang' : 'Ditutup',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              icon: isOpen && !_isRegistering ? const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22) : null,
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),

      bottomNavigationBar: MainFooterNav(
        currentIndex: 1,
        onItemSelected: _handleNav,
      ),
    );
  }

  Widget _buildHeaderDetail(detail, theme) {
    return Column(
      children: [
        Text(detail.namaEvent, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              detail.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(detail) {
    return Row(
      children: [
        Expanded(child: _DetailInfoBox(label: 'Lokasi', value: detail.tempatPelaksanaan, icon: Icons.location_on)),
        const SizedBox(width: 12),
        Expanded(child: _DetailInfoBox(label: 'Waktu', value: detail.waktuTanggalLabel, icon: Icons.access_time_filled)),
      ],
    );
  }

  Widget _buildSection(String title, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const SizedBox(height: 8),
        if (lines.isEmpty) const Text('-') else
          ...lines.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(l, style: const TextStyle(fontSize: 14, height: 1.5)))]),
          )).toList(),
      ],
    );
  }
}

class _DetailInfoBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailInfoBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

List<String> _splitLines(String raw) => raw.split(RegExp(r'\r?\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();