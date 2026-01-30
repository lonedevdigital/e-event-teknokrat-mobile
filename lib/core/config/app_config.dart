/// Konfigurasi global aplikasi (API base url, dll)
class AppConfig {
  /// Ganti dengan base URL API kamu
  static const String baseUrl = 'https://apievent.lonedev.my.id';

  /// Timeout koneksi (opsional)
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Timeout terima data (opsional)
  static const Duration receiveTimeout = Duration(seconds: 15);
}