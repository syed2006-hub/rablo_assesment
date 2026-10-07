import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_endpoints.dart';
import 'api_response.dart';
import 'auth_token_manager.dart';

/// Centralized HTTP REST Client supporting GET, POST, PUT, PATCH, DELETE
/// Built on top of GetConnect with live Firebase backend network communication and Bearer token injection.
class ApiClient extends GetConnect {
  static ApiClient get to => Get.find<ApiClient>();

  /// Test switch to simulate network timeouts or API failure for TL validation
  bool simulateNetworkFailure = false;

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = ApiEndpoints.baseUrl;
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      // Bearer JWT Token Injection
      if (Get.isRegistered<AuthTokenManager>()) {
        final authHeader = AuthTokenManager.to.authorizationHeader;
        if (authHeader != null) {
          request.headers['Authorization'] = authHeader;
        }
      }
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      debugPrint(
        '[API Client] ${request.method} ${request.url} -> ${response.statusCode}',
      );
      // Handle 401 Unauthorized token expiry
      if (response.statusCode == 401 && Get.isRegistered<AuthTokenManager>()) {
        debugPrint(
          '[API Client] 401 Unauthorized encountered. Clearing session.',
        );
        AuthTokenManager.to.clearToken();
      }
      return response;
    });
  }

  // ---------------------------------------------------------------------------
  // 1. HTTP GET
  // ---------------------------------------------------------------------------
  @override
  Future<Response<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    if (simulateNetworkFailure) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Response<T>(
        statusCode: 503,
        statusText: 'Simulated Network Failure: Host unreachable (503)',
      );
    }
    return super.get<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. HTTP POST
  // ---------------------------------------------------------------------------
  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    if (simulateNetworkFailure) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Response<T>(
        statusCode: 503,
        statusText: 'Simulated Network Failure: Host unreachable (503)',
      );
    }
    return super.post<T>(
      url,
      body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // 3. HTTP PUT
  // ---------------------------------------------------------------------------
  @override
  Future<Response<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    if (simulateNetworkFailure) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Response<T>(
        statusCode: 503,
        statusText: 'Simulated Network Failure: Host unreachable (503)',
      );
    }
    return super.put<T>(
      url,
      body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // 4. HTTP PATCH
  // ---------------------------------------------------------------------------
  @override
  Future<Response<T>> patch<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) async {
    if (simulateNetworkFailure) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Response<T>(
        statusCode: 503,
        statusText: 'Simulated Network Failure: Host unreachable (503)',
      );
    }
    return super.patch<T>(
      url,
      body,
      contentType: contentType,
      headers: headers,
      query: query,
      decoder: decoder,
      uploadProgress: uploadProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // 5. HTTP DELETE
  // ---------------------------------------------------------------------------
  @override
  Future<Response<T>> delete<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    if (simulateNetworkFailure) {
      await Future.delayed(const Duration(milliseconds: 600));
      return Response<T>(
        statusCode: 503,
        statusText: 'Simulated Network Failure: Host unreachable (503)',
      );
    }
    return super.delete<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
      decoder: decoder,
    );
  }

  // ---------------------------------------------------------------------------
  // Safe Envelope Helpers
  // ---------------------------------------------------------------------------
  ApiResponse<T> handleResponse<T>(Response response, {T? fallback}) {
    final status = response.statusCode ?? 500;
    final isOk = status >= 200 && status < 300;
    final body = response.body;

    if (isOk) {
      T? data;
      String msg = 'Success';
      if (body is Map) {
        if (body.containsKey('data')) {
          data = body['data'] as T?;
        }
        if (body.containsKey('message')) {
          msg = body['message'].toString();
        }
      }
      return ApiResponse.success(
        data: data ?? fallback as T,
        message: msg,
        statusCode: status,
        rawBody: body,
      );
    } else {
      String errorMsg = response.statusText ?? 'HTTP Error $status';
      Map<String, dynamic>? errs;
      if (body is Map) {
        if (body.containsKey('message') && body['message'] != null) {
          errorMsg = body['message'].toString();
        }
        if (body.containsKey('errors') && body['errors'] is Map) {
          errs = Map<String, dynamic>.from(body['errors']);
        }
      }
      return ApiResponse.error(
        message: errorMsg,
        statusCode: status,
        errors: errs,
        rawBody: body,
      );
    }
  }
}
