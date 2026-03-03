import 'package:flutter/material.dart'; // For WidgetsBinding
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import 'storage_service.dart';
import 'auth_service.dart'; // Added Import

class NetworkService extends GetxService {
  late Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();
  final Logger _logger = Logger();

  Future<NetworkService> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.read('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // 1. Handle 401 Unauthorized globally
          if (e.response?.statusCode == 401) {
            _logger.w('401 Unauthorized - Triggering auto-logout');
            // Prevent circular dependency issues by fetching AuthService lazily if needed
            // But usually Find is safe here if initialized
            if (Get.isRegistered<AuthService>()) {
              // Execute strictly in callback to avoid interfering with current stack
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                 await Get.find<AuthService>().logout();
              });
            }
          }

          // 2. Log the error
          _logger.e(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            error: e.error,
            stackTrace: e.stackTrace,
          );

          // 3. Normalize error for UI consumption (Optional but good for "Production Ready")
          // Logic could go here to wrap e in a custom 'Failure' object

          return handler.next(e);
        },
      ),
    );

    return this;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
