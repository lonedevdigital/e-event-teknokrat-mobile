// lib/core/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../../features/auth/auth_providers.dart';

class ApiClient {
  final Dio _dio;
  final Ref _ref;

  ApiClient(this._ref)
      : _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // AMBIL TOKEN DARI AUTH PROVIDER SECARA REAL-TIME
          final session = _ref.read(authProvider).asData?.value;
          if (session != null && session.token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${session.token}';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // JIKA MASIH 401, PAKSA LOGOUT AGAR USER BISA LOGIN ULANG SECARA BERSIH
          if (e.response?.statusCode == 401) {
            _ref.read(authProvider.notifier).logout();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) => _dio.get(path, queryParameters: queryParameters);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));