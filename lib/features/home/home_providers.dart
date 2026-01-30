import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_client.dart';
import '../../core/config/app_config.dart';

/// Helper format tanggal jadi "03 Agu 2025"
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

/// =============================================================
/// MODEL & PROVIDER LIST EVENT (/api/events)
/// =============================================================

/// Model event sesuai response /api/events
class HomeEventData {
  final int id;
  final String slug;
  final String namaEvent;
  final String thumbnail; // path relatif, misal: storage/event_covers/sample1.jpg
  final String tempatPelaksanaan;
  final String waktuPelaksanaan;
  final String? tanggalPelaksanaan; // "2025-12-12"
  final String deskripsi;
  final String status;
  final String? kategori; // category.nama_kategori

  const HomeEventData({
    required this.id,
    required this.slug,
    required this.namaEvent,
    required this.thumbnail,
    required this.tempatPelaksanaan,
    required this.waktuPelaksanaan,
    required this.tanggalPelaksanaan,
    required this.deskripsi,
    required this.status,
    required this.kategori,
  });

  factory HomeEventData.fromJson(Map<String, dynamic> json) {
    return HomeEventData(
      id: json['id'] as int,
      slug: json['slug'] as String,
      namaEvent: json['nama_event'] as String,
      thumbnail: json['thumbnail'] as String,
      tempatPelaksanaan: json['tempat_pelaksanaan'] as String,
      waktuPelaksanaan: json['waktu_pelaksanaan'] as String,
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] as String?,
      deskripsi: json['deskripsi'] as String? ?? '',
      status: json['status'] as String? ?? '',
      kategori: (json['category'] is Map &&
          json['category']?['nama_kategori'] != null)
          ? json['category']['nama_kategori'] as String
          : null,
    );
  }

  /// URL gambar full untuk dipakai di Image.network
  String get imageUrl => '${AppConfig.baseUrl}/$thumbnail';

  /// Teks tanggal untuk ditampilkan di badge (contoh: 03 Agu 2025)
  String get dateText => _formatTanggal(tanggalPelaksanaan);
}

/// Provider Future untuk mengambil list event dari API.
/// GET /api/events
final homeEventsProvider = FutureProvider<List<HomeEventData>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.get('/api/events');
  final data = response.data;

  if (data is! Map<String, dynamic>) {
    throw Exception('Format response /api/events tidak sesuai');
  }

  final list = data['data'];
  if (list is! List) {
    throw Exception('Field "data" bukan List');
  }

  return list
      .map((e) => HomeEventData.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

/// =============================================================
/// MODEL & PROVIDER SLIDER EVENT (/api/sliders)
/// =============================================================

class HomeSliderEvent {
  final String slug;
  final String namaEvent;
  final String thumbnail;
  final String tanggalPelaksanaan;
  final String waktuPelaksanaan;
  final String tempatPelaksanaan;
  final String status;
  final int jumlahPeserta;

  const HomeSliderEvent({
    required this.slug,
    required this.namaEvent,
    required this.thumbnail,
    required this.tanggalPelaksanaan,
    required this.waktuPelaksanaan,
    required this.tempatPelaksanaan,
    required this.status,
    required this.jumlahPeserta,
  });

  factory HomeSliderEvent.fromJson(Map<String, dynamic> json) {
    return HomeSliderEvent(
      slug: json['slug']?.toString() ?? '',
      namaEvent: json['nama_event']?.toString() ?? 'Tanpa judul',
      thumbnail: json['thumbnail']?.toString() ?? '',
      tanggalPelaksanaan: json['tanggal_pelaksanaan']?.toString() ?? '',
      waktuPelaksanaan: json['waktu_pelaksanaan']?.toString() ?? '',
      tempatPelaksanaan: json['tempat_pelaksanaan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      jumlahPeserta: json['jumlah_peserta'] is int
          ? json['jumlah_peserta'] as int
          : int.tryParse(json['jumlah_peserta']?.toString() ?? '0') ?? 0,
    );
  }

  String get imageUrl => '${AppConfig.baseUrl}/$thumbnail';
  String get dateText => _formatTanggal(tanggalPelaksanaan);
}

/// GET /api/sliders
final homeSliderEventsProvider =
FutureProvider<List<HomeSliderEvent>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.get('/api/sliders');
  final data = response.data;

  if (data is! Map<String, dynamic>) {
    throw Exception('Format response /api/sliders tidak sesuai');
  }

  final list = data['data'];
  if (list is! List) {
    throw Exception('Field "data" bukan List');
  }

  return list
      .map((e) => HomeSliderEvent.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

/// =============================================================
/// MODEL & PROVIDER DOKUMENTASI (/api/documentation)
/// =============================================================

class HomeDocumentationData {
  final int id;
  final String namaEvent;
  final String? tanggalPelaksanaan;
  final String? thumbnail; // boleh null

  const HomeDocumentationData({
    required this.id,
    required this.namaEvent,
    required this.tanggalPelaksanaan,
    required this.thumbnail,
  });

  factory HomeDocumentationData.fromJson(Map<String, dynamic> json) {
    return HomeDocumentationData(
      id: json['id'] as int,
      namaEvent: json['nama_event'] as String,
      tanggalPelaksanaan: json['tanggal_pelaksanaan'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  /// URL gambar full (boleh null kalau thumbnail null)
  String? get imageUrl =>
      (thumbnail == null || thumbnail!.isEmpty)
          ? null
          : '${AppConfig.baseUrl}/$thumbnail';

  /// Teks tanggal untuk ditampilkan (contoh: 02 Des 2025)
  String get dateText => _formatTanggal(tanggalPelaksanaan);
}

/// GET /api/documentation
final homeDocumentationProvider =
FutureProvider<List<HomeDocumentationData>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.get('/api/documentation');
  final data = response.data;

  if (data is! Map<String, dynamic>) {
    throw Exception('Format response /api/documentation tidak sesuai');
  }

  final list = data['data'];
  if (list is! List) {
    throw Exception('Field "data" bukan List');
  }

  return list
      .map(
        (e) => HomeDocumentationData.fromJson(
      Map<String, dynamic>.from(e),
    ),
  )
      .toList();
});
