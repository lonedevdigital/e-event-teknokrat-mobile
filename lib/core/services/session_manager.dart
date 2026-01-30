// lib/core/services/session_manager.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KEY di SharedPreferences
const _keyLoginData = 'login_data_json';
const _keyAuthToken = 'auth_token';

/// =======================
/// MODEL
/// =======================

class SessionUser {

  final int id;
  final String name;
  final String username;
  final String email;
  final String role;

  const SessionUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'role': role,
  };
}

class SessionMahasiswa {
  final int id;
  final int userId;
  final String npm;
  final String nama;
  final String namaProdi;
  final String namaFakultas;
  final String angkatan;

  const SessionMahasiswa({
    required this.id,
    required this.userId,
    required this.npm,
    required this.nama,
    required this.namaProdi,
    required this.namaFakultas,
    required this.angkatan,
  });

  factory SessionMahasiswa.fromJson(Map<String, dynamic> json) {
    return SessionMahasiswa(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      npm: json['npm_mahasiswa'] as String,
      nama: json['nama_mahasiswa'] as String,
      namaProdi: json['nama_program_studi'] as String? ?? '',
      namaFakultas: json['nama_fakultas'] as String? ?? '',
      angkatan: json['angkatan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'npm_mahasiswa': npm,
    'nama_mahasiswa': nama,
    'nama_program_studi': namaProdi,
    'nama_fakultas': namaFakultas,
    'angkatan': angkatan,
  };
}

/// Representasi data login yang disimpan di session
class LoginSession {
  final SessionUser user;
  final SessionMahasiswa mahasiswa;
  final String token;

  const LoginSession({
    required this.user,
    required this.mahasiswa,
    required this.token,
  });


  factory LoginSession.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final userJson = data['user'] as Map<String, dynamic>;
    final mhsJson = data['mahasiswa'] as Map<String, dynamic>;
    final token = data['token'] as String;

    return LoginSession(
      user: SessionUser.fromJson(userJson),
      mahasiswa: SessionMahasiswa.fromJson(mhsJson),
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'mahasiswa': mahasiswa.toJson(),
    'token': token,
  };

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    return LoginSession(
      user: SessionUser.fromJson(json['user'] as Map<String, dynamic>),
      mahasiswa:
      SessionMahasiswa.fromJson(json['mahasiswa'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

/// =======================
/// SESSION MANAGER
/// =======================

class SessionManager {
  /// Simpan data login dan token ke SharedPreferences
  Future<void> saveLoginSession(LoginSession session) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(session.toJson());

    await prefs.setString(_keyLoginData, jsonString);
    await prefs.setString(_keyAuthToken, session.token);
  }

  /// Ambil session login (kalau ada).
  /// Return null kalau belum login / belum disimpan.
  Future<LoginSession?> loadLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLoginData);

    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> map =
      jsonDecode(jsonString) as Map<String, dynamic>;
      return LoginSession.fromJson(map);
    } catch (_) {
      // kalau gagal decode, hapus saja biar gak bikin error terus
      await clearSession();
      return null;
    }
  }

  /// Ambil token saja (kalau mau pakai cepat)
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// Hapus semua data session (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginData);
    await prefs.remove(_keyAuthToken);
  }
}

/// Provider Riverpod untuk SessionManager
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

/// Provider Future untuk session saat ini (kalau mau cek user sudah login/belum)
final currentSessionProvider = FutureProvider<LoginSession?>((ref) async {
  final manager = ref.watch(sessionManagerProvider);
  return manager.loadLoginSession();
});
