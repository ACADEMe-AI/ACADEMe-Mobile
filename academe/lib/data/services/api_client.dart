import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/result.dart';
import '../model/api_models.dart';

class ApiClient {
  ApiClient({required Uri baseUrl, http.Client? client})
    : _baseUrl = baseUrl,
      _client = client ?? http.Client();

  final Uri _baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  Future<Result<T>> send<T>(
    String method,
    String path, {
    required T Function(Map<String, Object?> json) parse,
    Map<String, Object?>? body,
    Map<String, String>? fields,
    List<String>? files,
    String? accessToken,
    Duration timeout = _timeout,
  }) async {
    final url = _baseUrl.resolve(path);
    final http.BaseRequest request;
    final http.Response response;
    try {
      if (files != null) {
        request = http.MultipartRequest(method, url)
          ..fields.addAll(fields ?? const {})
          ..files.addAll([
            for (final file in files)
              await http.MultipartFile.fromPath('page', file),
          ]);
      } else {
        request = http.Request(method, url);
        if (body != null) {
          (request as http.Request)
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode(body);
        }
      }
      request.headers['Accept'] = 'application/json';
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      response = await http.Response.fromStream(
        await _client.send(request).timeout(timeout),
      ).timeout(timeout);
    } on Exception {
      return Result.error(const ApiException(ApiException.network));
    }

    try {
      final json = response.body.isEmpty
          ? const <String, Object?>{}
          : jsonDecode(response.body) as Map<String, Object?>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Result.ok(parse(json));
      }
      final error = json['error'] as Map<String, Object?>?;
      return Result.error(
        ApiException(
          error?['code'] as String? ?? ApiException.invalidResponse,
          statusCode: response.statusCode,
          details: error?['details'] as Map<String, Object?>? ?? const {},
        ),
      );
    } on Object {
      return Result.error(
        ApiException(
          ApiException.invalidResponse,
          statusCode: response.statusCode,
        ),
      );
    }
  }
}
