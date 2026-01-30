// lib/features/home/event/event_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/app_client.dart';

/// Helper format tanggal
String _formatTanggal(String? tanggal) {
  if (tanggal == null || tanggal.isEmpty) return '';
  final dt = DateTime.tryParse(tanggal);
  if (dt == null) return '';
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final b = bulan[dt.month - 1];
  final hari = dt.day.toString().padLeft(2, '0');
  return '$hari $b ${dt.year}';
}

/// =======================================================
/// MODEL DETAIL EVENT  (GET /api/events/{slug})
/// =======================================================
class EventDetailData {
  final int id;
  final String slug;
  final String namaEvent;
  final String thumbnail; // path relatif
  final String tempatPelaksanaan;
  final String waktuPelaksanaan;
  final String? tanggalPelaksanaan;
  final String deskripsi;
  final String informasiLainnya;
  final String status;
  final int jumlahPeserta;
  final String? kategori;

  EventDetailData({
    required this.id,
    required this.slug,
    required this.namaEvent,
    required this.thumbnail,
    required this.tempatPelaksanaan,
    required this.waktuPelaksanaan,
    required this.tanggalPelaksanaan,
    required this.deskripsi,
    required this.informasiLainnya,
    required this.status,
    required this.jumlahPeserta,
    required this.kategori,
  });

  factory EventDetailData.fromJson(Map<String, dynamic> json) {
    return EventDetailData(
      id: json['id'] as int,
      slug: json['slug'] as String,
      namaEvent: json['nama_event'] as String,
      thumbnail: json['thumbnail']?.toString() ?? '',
      tempatPelaksanaan: json['tempat_pelaksanaan']?.toString() ?? '-',
      waktuPelaksanaan: json['waktu_pelaksanaan']?.toString() ?? '-',
      tanggalPelaksanaan: json['tanggal_pelaksanaan']?.toString(),
      deskripsi: json['deskripsi']?.toString() ?? '',
      informasiLainnya: json['informasi_lainnya']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      jumlahPeserta: json['jumlah_peserta'] is int
          ? json['jumlah_peserta'] as int
          : int.tryParse(json['jumlah_peserta']?.toString() ?? '0') ?? 0,
      kategori: (json['category'] is Map &&
          json['category']?['nama_kategori'] != null)
          ? json['category']['nama_kategori'] as String
          : null,
    );
  }

  /// URL gambar full untuk dipakai di Image.network
  String get imageUrl =>
      thumbnail.isEmpty ? '' : '${AppConfig.baseUrl}/$thumbnail';

  /// Format tanggal "03 Agu 2025"
  String get tanggalFormatted => _formatTanggal(tanggalPelaksanaan);

  /// Label gabungan tanggal + waktu
  String get waktuTanggalLabel {
    final tgl = tanggalFormatted;
    final jam = waktuPelaksanaan;
    if (tgl.isEmpty && jam.isEmpty) return '-';
    if (tgl.isEmpty) return jam;
    if (jam.isEmpty) return tgl;
    return '$tgl • $jam';
  }
}


/// GET /api/events/{slug}
final eventDetailProvider =
FutureProvider.family<EventDetailData, String>((ref, slug) async {
  final api = ref.watch(apiClientProvider);

  final res = await api.get('/api/events/$slug');
  final data = res.data;

  if (data is! Map<String, dynamic>) {
    throw Exception('Format response /api/events/$slug tidak sesuai');
  }

  final detail = data['data'];
  if (detail is! Map<String, dynamic>) {
    throw Exception('Field "data" bukan objek');
  }

  return EventDetailData.fromJson(
    Map<String, dynamic>.from(detail),
  );
});

/// =======================================================
/// MODEL MY EVENTS (GET /api/mahasiswa/my-events)
/// =======================================================
class MyEventData {
  final int registrationId;
  final int eventId;
  final String slug;
  final String namaEvent;
  final String thumbnail; // path relatif
  final String tempat;
  final String tanggal;
  final String waktu;
  final String statusDaftar;
  final String? attendanceAt;
  final String? certificateUrl;

  const MyEventData({
    required this.registrationId,
    required this.eventId,
    required this.slug,
    required this.namaEvent,
    required this.thumbnail,
    required this.tempat,
    required this.tanggal,
    required this.waktu,
    required this.statusDaftar,
    required this.attendanceAt,
    required this.certificateUrl,
  });

  factory MyEventData.fromJson(Map<String, dynamic> json) {
    return MyEventData(
      registrationId: json['registration_id'] as int,
      eventId: json['event_id'] as int,
      slug: json['slug']?.toString() ?? '',
      namaEvent: json['nama_event']?.toString() ?? 'Tanpa judul',
      thumbnail: json['thumbnail']?.toString() ?? '',
      tempat: json['tempat']?.toString() ?? '-',
      tanggal: json['tanggal']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',
      statusDaftar: json['status_daftar']?.toString() ?? '',
      attendanceAt: json['attendance_at']?.toString(),
      certificateUrl: json['certificate_url']?.toString(),
    );
  }

  String get imageUrl =>
      thumbnail.isEmpty ? '' : '${AppConfig.baseUrl}/$thumbnail';

  String get tanggalText => _formatTanggal(tanggal);

  String get pelaksanaanLabel {
    final tgl = tanggalText.isEmpty ? '-' : tanggalText;
    final wkt = waktu.isEmpty ? '-' : waktu;
    final tmp = tempat.isEmpty ? '-' : tempat;
    return 'Tanggal: $tgl\nWaktu: $wkt\nTempat: $tmp';
  }

  bool get sudahHadir => attendanceAt != null && attendanceAt!.isNotEmpty;

  String get statusLabel {
    if (sudahHadir) return 'Hadir';
    if (statusDaftar.isEmpty) return '-';
    return statusDaftar[0].toUpperCase() + statusDaftar.substring(1);
  }
}

/// PROVIDER MY EVENTS
/// GET /api/mahasiswa/my-events
final myEventsProvider = FutureProvider<List<MyEventData>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final res = await api.get('/api/mahasiswa/my-events');
  final data = res.data;

  if (data is! Map<String, dynamic>) {
    throw Exception('Format response /api/mahasiswa/my-events tidak sesuai');
  }

  final list = data['data'];
  if (list is! List) {
    throw Exception('Field "data" bukan List');
  }

  return list
      .map((e) => MyEventData.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});
