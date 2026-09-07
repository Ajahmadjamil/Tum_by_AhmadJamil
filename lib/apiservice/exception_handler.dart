// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
//
// /// Mapped API / network failure with a user-facing message.
// class ApiException implements Exception {
//   const ApiException(
//     this.message, {
//     this.statusCode,
//     this.retryAfterMs,
//     this.hasResponse = false,
//     this.canRetry = false,
//   });
//
//   /// Backend `error` / `message` text. Empty when the API sent no body.
//   final String message;
//   final int? statusCode;
//   final int? retryAfterMs;
//
//   /// True when the server returned an HTTP response (including error bodies).
//   final bool hasResponse;
//
//   /// True when there was no usable response and the call can be retried.
//   final bool canRetry;
//
//   @override
//   String toString() => message;
// }
//
// /// Maps Dio / HTTP failures into [ApiException].
// abstract final class ExceptionHandler {
//   static ApiException fromDio(DioException error) {
//     if (error.response != null) {
//       return fromResponse(error.response!);
//     }
//
//     _debugDumpNoResponse(error);
//
//     final cancelled = error.type == DioExceptionType.cancel;
//     return ApiException(
//       '',
//       canRetry: !cancelled,
//       hasResponse: false,
//     );
//   }
//
//   static ApiException fromResponse(Response response) {
//     _debugDumpResponse(response);
//
//     final code = response.statusCode;
//     final message = extractErrorMessage(response);
//     final retryAfterMs = extractRetryAfterMs(response);
//
//     return ApiException(
//       message,
//       statusCode: code,
//       retryAfterMs: retryAfterMs,
//       hasResponse: true,
//       canRetry: message.isEmpty,
//     );
//   }
//
//   /// Prefers the API `error` / `message` field as the user-facing text.
//   static String extractErrorMessage(Response response) {
//     try {
//       final data = response.data;
//       if (data == null) return '';
//
//       if (data is String) {
//         final trimmed = data.trim();
//         if (trimmed.isEmpty) return '';
//         try {
//           final decoded = jsonDecode(trimmed);
//           return _messageFromDecoded(decoded);
//         } catch (_) {
//           return trimmed;
//         }
//       }
//
//       return _messageFromDecoded(data);
//     } catch (_) {
//       return '';
//     }
//   }
//
//   static String _messageFromDecoded(dynamic decoded) {
//     if (decoded is String) return decoded.trim();
//     if (decoded is Map) return _messageFromMap(decoded);
//     if (decoded is List) {
//       for (final item in decoded) {
//         final nested = _messageFromDecoded(item);
//         if (nested.isNotEmpty) return nested;
//       }
//     }
//     return '';
//   }
//
//   static String _messageFromMap(Map decoded) {
//     for (final key in ['error', 'message', 'msg', 'detail', 'title']) {
//       final value = decoded[key];
//       if (value is String && value.trim().isNotEmpty) return value.trim();
//       if (value is Map) {
//         final nested = _messageFromMap(value);
//         if (nested.isNotEmpty) return nested;
//       }
//       if (value is List) {
//         final nested = _messageFromDecoded(value);
//         if (nested.isNotEmpty) return nested;
//       }
//     }
//
//     final errors = decoded['errors'];
//     if (errors is List) {
//       final nested = _messageFromDecoded(errors);
//       if (nested.isNotEmpty) return nested;
//     }
//     return '';
//   }
//
//   static int? extractRetryAfterMs(Response response) {
//     try {
//       final data = response.data;
//       final decoded = data is String ? jsonDecode(data) : data;
//       if (decoded is! Map) return null;
//       final details = decoded['details'];
//       if (details is! Map) return null;
//       final value = details['retryAfterMs'];
//       if (value is int) return value;
//       if (value is num) return value.toInt();
//       return int.tryParse(value?.toString() ?? '');
//     } catch (_) {
//       return null;
//     }
//   }
//
//   static bool isSuccessResponse(Response response) {
//     return response.statusCode == 200 ||
//         response.statusCode == 201 ||
//         response.statusCode == 204;
//   }
//
//   static void _debugDumpResponse(Response response) {
//     if (!kDebugMode) return;
//     _debugLog('API ERROR RESPONSE status=${response.statusCode}');
//     _debugLog('API ERROR HEADERS: ${response.headers.map}');
//     _debugLog('API ERROR BODY:\n${prettyJson(response.data)}');
//   }
//
//   static void _debugDumpNoResponse(DioException error) {
//     if (!kDebugMode) return;
//     _debugLog(
//       'API ERROR (no response) type=${error.type} message=${error.message}',
//     );
//     if (error.error != null) {
//       _debugLog('API ERROR CAUSE: ${error.error}');
//     }
//   }
//
//   static String prettyJson(dynamic data) {
//     try {
//       if (data == null) return '<empty>';
//       if (data is String) {
//         final trimmed = data.trim();
//         if (trimmed.isEmpty) return '<empty string>';
//         try {
//           final decoded = jsonDecode(trimmed);
//           return const JsonEncoder.withIndent('  ').convert(decoded);
//         } catch (_) {
//           return data;
//         }
//       }
//       return const JsonEncoder.withIndent('  ').convert(data);
//     } catch (_) {
//       return data.toString();
//     }
//   }
//
//   static void _debugLog(String message) {
//     const chunk = 800;
//     for (var i = 0; i < message.length; i += chunk) {
//       final end = (i + chunk < message.length) ? i + chunk : message.length;
//       debugPrint(message.substring(i, end));
//     }
//   }
// }
