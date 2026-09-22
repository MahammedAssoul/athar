import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/token_storage.dart';
import 'api_config.dart';
import 'api_endpoints.dart';
import 'api_error.dart';

/// Low-level HTTP client for the Athar backend.
///
/// Responsibilities:
/// - builds absolute URLs from [ApiConfig] + [ApiEndpoints]
/// - attaches the bearer token when present
/// - refreshes the access token on 401 (once)
/// - converts transport/HTTP errors into [ApiException]
///
/// Widgets never use this class directly — repositories do.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Performs a GET request.
  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = true,
  }) {
    return _send('GET', path, query: query, authenticated: authenticated);
  }

  /// Performs a POST request with an optional JSON body.
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      query: query,
      authenticated: authenticated,
    );
  }

  /// Performs a PUT request with an optional JSON body.
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send('PUT', path, body: body, authenticated: authenticated);
  }

  /// Performs a PATCH request with an optional JSON body.
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return _send('PATCH', path, body: body, authenticated: authenticated);
  }

  /// Performs a DELETE request.
  Future<dynamic> delete(String path, {bool authenticated = true}) {
    return _send('DELETE', path, authenticated: authenticated);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path, query);
    final headers = Map<String, String>.of(ApiConfig.defaultHeaders);

    if (authenticated) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamed = await _client.send(request).timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);

      // ── Token refresh on 401 ────────────────────────────
      if (response.statusCode == 401 && authenticated) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          headers['Authorization'] =
              'Bearer ${await TokenStorage.getAccessToken()}';
          final retry = http.Request(method, uri)..headers.addAll(headers);
          if (body != null) {
            retry.body = jsonEncode(body);
          }
          final retryStreamed = await _client
              .send(retry)
              .timeout(ApiConfig.timeout);
          final retryResponse = await http.Response.fromStream(retryStreamed);
          return _decode(retryResponse);
        }
      }

      return _decode(response);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout);
    } on http.ClientException {
      throw const ApiException(ApiErrorType.network);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiErrorMapper.from(e);
    }
  }

  /// Attempts to refresh the access token using the refresh token.
  Future<bool> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.apiRoot}${ApiEndpoints.refreshToken}'),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode != 200) {
        await TokenStorage.clearTokens();
        return false;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null) {
        await TokenStorage.clearTokens();
        return false;
      }
      await TokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh ?? refreshToken,
      );
      return true;
    } catch (_) {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  /// Decodes a response body into JSON, throwing typed errors.
  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw ApiException(
      ApiErrorMapper.typeFromStatus(response.statusCode),
      statusCode: response.statusCode,
      message: _extractMessage(response.body),
    );
  }

  String? _extractMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String) return message;
      }
    } catch (_) {
      // Not JSON — ignore.
    }
    return null;
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final base = ApiConfig.effectiveBaseUrl;
    final root = '$base/${ApiConfig.apiVersion}';
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$root$normalized');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }
}
