import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, Response;

import '../../app/app_routes.dart';

import '../../components/app_buttons.dart';
import '../../components/app_logger.dart';

import '../../services/session_service.dart';
import 'api_constants.dart';
import 'api_interceptor.dart';

class ApiServices extends GetxService {
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {"Accept": "application/json, text/xml, */*"},
        validateStatus: (status) {
          return status != null && status > 0;
        },
      ),
    );
    if (kDebugMode) _dio.interceptors.add(_buildLogger());
    _dio.interceptors.add(_buildRetry());
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  LogInterceptor _buildLogger() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    );
  }

  RetryInterceptor _buildRetry() {
    return RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryEvaluator: (error, attempt) {
        return error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout;
      },
    );
  }

  void logApiError(String message) {
    printMessage("⚠️ API Error: $message");
  }

  Future<Map<String, String>> _getHeaders(bool isUserRequired) async {
    final headers = <String, String>{
      "Accept": "application/json",
      "X-Tenant-ID": "1",
      "X-App-Key": ApiConstants.appKey,
    };
    if (Get.isRegistered<SessionService>()) {
      final session = Get.find<SessionService>();
      final token = session.authToken.value;
      if (isUserRequired && token.isNotEmpty) {
        if (token.startsWith('Bearer ')) {
          headers[ApiKeys.authorization] = token;
        } else {
          headers[ApiKeys.authorization] = 'Bearer $token';
        }
      }
    }
    return headers;
  }

  Future<ResponseModel> get(
    String urlOrEndpoint, {
    Map<String, dynamic>? queryParameters,
    bool isUserRequired = true,
  }) async {
    final headers = await _getHeaders(isUserRequired);

    final options = Options(headers: headers, responseType: ResponseType.json);

    printMessage("📡 GET [$urlOrEndpoint] Query: $queryParameters");

    final response = await _dio.get(
      urlOrEndpoint,
      queryParameters: queryParameters,
      options: options,
    );

    return await checkResponseModel(response);
  }

  /// 📡 Generic POST API Call
  Future<ResponseModel> post(
    String urlOrEndpoint, {
    dynamic req,
    FormData? multipartRequest,
    bool isUserRequired = true,
  }) async {
    final headers = await _getHeaders(isUserRequired);

    dynamic requestData;
    String contentType;

    if (multipartRequest != null) {
      requestData = multipartRequest;
      contentType = "multipart/form-data";
    } else {
      requestData = req ?? <String, dynamic>{};
      contentType = "application/json";
    }

    final options = Options(
      headers: headers,
      contentType: contentType,
      responseType: ResponseType.json,
    );

    printMessage(
      "📡 POST [$urlOrEndpoint] ContentType: $contentType Request $req",
    );

    final response = await _dio.post(
      urlOrEndpoint,
      data: requestData,
      options: options,
    );

    return await checkResponseModel(response);
  }

  /// 📡 Generic PUT API Call
  Future<ResponseModel> callPutApi(
    String urlOrEndpoint, {
    dynamic req,
    bool isUserRequired = true,
  }) async {
    final headers = await _getHeaders(isUserRequired);

    final options = Options(
      headers: headers,
      contentType: "application/json",
      responseType: ResponseType.json,
    );

    printMessage("📡 PUT [$urlOrEndpoint] Request $req");

    final response = await _dio.put(
      urlOrEndpoint,
      data: req ?? <String, dynamic>{},
      options: options,
    );

    return await checkResponseModel(response);
  }

  /// 📡 Generic DELETE API Call
  Future<ResponseModel> callDeleteApi(
    String urlOrEndpoint, {
    dynamic req,
    Map<String, dynamic>? queryParameters,
    bool isUserRequired = true,
  }) async {
    final headers = await _getHeaders(isUserRequired);

    final options = Options(
      headers: headers,
      contentType: "application/json",
      responseType: ResponseType.json,
    );

    printMessage(
      "📡 DELETE [$urlOrEndpoint] Request $req Query $queryParameters",
    );

    final response = await _dio.delete(
      urlOrEndpoint,
      data: req,
      queryParameters: queryParameters,
      options: options,
    );

    return await checkResponseModel(response);
  }

  Future<ResponseModel> checkResponseModel(Response res) async {
    printMessage("Status Code: ${res.statusCode}");
    printMessage("Status Message: ${res.statusMessage}");
    printMessage("Raw Response Data: ${jsonEncode(res.data)}");

    dynamic rd = res.data;
    if (rd is String) {
      try {
        rd = jsonDecode(rd);
      } catch (e) {
        printMessage('⚠️ jsonDecode Exception: $e');
      }
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      final rawData = res.data;
      bool status = true;
      String message = '';
      if (rawData is Map) {
        if (rawData.containsKey('status')) {
          status = rawData['status'] == true;
        } else if (rawData.containsKey(ApiKeys.success)) {
          status = rawData[ApiKeys.success] == true;
        }
        if (rawData[ApiKeys.message] is String) {
          message = rawData[ApiKeys.message] as String;
        }
      }
      final data = formatResponse(rawData);
      dynamic resolvedData;
      if (status) {
        resolvedData = data;
      }
      return ResponseModel(status, message, resolvedData, raw: rawData);
    }

    if (res.statusCode == 401) {
      final msg = rd['message'] ?? "Session Expired : Re-Login";
      await _showSessionExpiredDialog(msg);
      return ResponseModel(false, msg, null);
    }

    final msg = rd['message']?.toString() ?? "Internal Server Error";

    return ResponseModel(false, msg, null);
  }
}

dynamic formatResponse(dynamic data) {
  if (data is Map) {
    if (data.containsKey("data")) {
      return data['data'];
    }

    if (data.containsKey("notifications")) {
      return data['notifications'];
    }

    if (data.containsKey("users")) {
      return data['users'];
    }

    if (data.containsKey("user")) {
      return data['user'];
    }

    if (data.containsKey("plans")) {
      return data['plans'];
    }

    if (data.containsKey("banners")) {
      return data['banners'];
    }

    if (data.containsKey("requests")) {
      return data['requests'];
    }

    if (data.containsKey("messages")) {
      return data['messages'];
    }

    if (data.containsKey("user")) {
      return data['user'];
    }

    if (data.containsKey("message")) {
      return data['message'];
    }
  }
  return data;
}

class ApiKeys {
  ApiKeys._();

  static const String success = "success";
  static const String response = "data";
  static const String user = "user";
  static const String message = "message";
  static const String authorization = "Authorization";
  static const String token = "token";
  static const String xAppVersion = "X-App-Version";
}

class ResponseModel {
  final bool _status;
  final String _message;
  final dynamic _data;
  final dynamic raw;

  ResponseModel(this._status, this._message, this._data, {this.raw});

  String get message => _message;

  bool get status => _status;

  dynamic get data => _data;
}

Future<void> _showSessionExpiredDialog(String message) async {
  Get.find<SessionService>().logout();
  await Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Alert !!",
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              onTap: () {
                if (Get.currentRoute == AppRoutes.login) {
                  Get.back();
                } else {
                  Get.back();
                  Get.offAllNamed(AppRoutes.login);
                }
              },
              title: "Login",
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}
