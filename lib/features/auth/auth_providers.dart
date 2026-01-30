// lib/features/auth/auth_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_client.dart';      // ApiClient
import '../../core/services/session_manager.dart'; // LoginSession & SessionManager

/// Provider global untuk auth (Riverpod 3.0.3)
/// State: LoginSession? (null = belum login)
final authProvider = AsyncNotifierProvider<AuthNotifier, LoginSession?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<LoginSession?> {
  late SessionManager _sessionManager;

  @override
  Future<LoginSession?> build() async {
    _sessionManager = ref.read(sessionManagerProvider);

    // Muat session dari penyimpanan lokal saat aplikasi dimulai
    return await _sessionManager.loadLoginSession();
  }

  // Getter helper untuk UI
  bool get isLoggedIn => state.asData?.value != null;
  LoginSession? get session => state.asData?.value;

  /// ======================
  /// LOGIN
  /// ======================
  Future<void> login({
    required String npm,
    required String password,
  }) async {
    // Set state ke loading agar UI menampilkan spinner
    state = const AsyncLoading();

    // Ambil instance ApiClient
    final api = ref.read(apiClientProvider);

    try {
      final res = await api.post(
        '/api/mahasiswa/login',
        data: {
          'npm': npm,
          'password': password,
        },
      );

      final body = res.data as Map<String, dynamic>;

      // Validasi status dari backend
      if (body['status'] != true) {
        final msg = body['message']?.toString() ?? 'Login gagal';
        throw Exception(msg);
      }

      // 1. Buat objek session dari response
      final session = LoginSession.fromApiResponse(body);

      // 2. Simpan ke SharedPreferences (Permanen)
      await _sessionManager.saveLoginSession(session);

      // 3. Update State
      state = AsyncData(session);

    } on DioException catch (e, st) {
      // Handle Error dari Dio (Koneksi / Validasi Backend)
      final data = e.response?.data;
      String msg = 'Login gagal';

      if (data is Map) {
        if (data['errors'] is Map) {
          // Parsing error validasi Laravel
          final errors = data['errors'] as Map;
          final allMessages = <String>[];
          for (final entry in errors.entries) {
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              allMessages.add(val.first.toString());
            } else if (val is String) {
              allMessages.add(val);
            }
          }
          if (allMessages.isNotEmpty) msg = allMessages.join('\n');
        } else if (data['message'] is String) {
          msg = data['message'] as String;
        }
      } else if (e.message != null) {
        msg = 'Koneksi error: ${e.message}';
      }

      // Set state ke error agar UI bisa menampilkan pesan kesalahan
      state = AsyncError(Exception(msg), st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  } // <--- KURUNG KURAWAL PENUTUP LOGIN YANG HILANG SEBELUMNYA

  /// ======================
  /// LOGOUT
  /// ======================
  Future<void> logout() async {
    // 1. Hapus data session dari storage HP
    await _sessionManager.clearSession();

    // 2. Reset state auth menjadi null
    state = const AsyncData(null);
  }
} // <--- KURUNG KURAWAL PENUTUP CLASS