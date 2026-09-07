// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
//
// import '../core/constants/app_constants.dart';
// import 'api_end_points.dart';
// import 'exception_handler.dart';
//
// /// Shared Dio client for the Aaj Kya Pakayein backend API.
// ///
// /// Sends `x-api-key` on all requests. Optionally attaches
// /// `Authorization: Bearer <token>` when [authTokenProvider] returns a token
// /// or when [authToken] is passed per call.
// ///
// /// On HTTP 429, waits `details.retryAfterMs` then retries once.
// class ApiService {
//   ApiService({
//     Dio? dio,
//     String? Function()? authTokenProvider,
//   })  : _dio = dio ??
//       Dio(
//         BaseOptions(
//           connectTimeout: AppConstants.apiTimeout,
//           receiveTimeout: AppConstants.apiTimeout,
//           sendTimeout: AppConstants.apiTimeout,
//           responseType: ResponseType.json,
//           headers: const {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//             'x-api-key': ApiEndPoints.apiKey,
//           },
//         ),
//       ),
//         _authTokenProvider = authTokenProvider;
//
//   final Dio _dio;
//   final String? Function()? _authTokenProvider;
//
//   Future<Response> getRequestResponse(
//     String url, {
//     String? authToken,
//     bool requireAuth = false,
//     bool silent = false,
//   }) async {
//     final options = _authOptions(authToken: authToken, requireAuth: requireAuth);
//     _logRequest(method: 'GET', url: url);
//     try {
//       final response = await _dio.get(url, options: options);
//       _logResponse(method: 'GET', url: url, response: response);
//       if (!ExceptionHandler.isSuccessResponse(response)) {
//         throw ExceptionHandler.fromResponse(response);
//       }
//       return response;
//     } on DioException catch (e) {
//       _logDioError(method: 'GET', url: url, error: e);
//       throw ExceptionHandler.fromDio(e);
//     }
//   }
//
//   Future<Response> postRequestResponse(
//     String url, {
//     Map<String, dynamic>? body,
//     String? authToken,
//     bool requireAuth = false,
//     int maxRetries = 1,
//   }) async {
//     var attempt = 0;
//     while (true) {
//       final options =
//           _authOptions(authToken: authToken, requireAuth: requireAuth);
//       _logRequest(method: 'POST', url: url, body: body, attempt: attempt);
//       try {
//         final response = await _dio.post(url, data: body, options: options);
//         _logResponse(method: 'POST', url: url, response: response);
//         if (!ExceptionHandler.isSuccessResponse(response)) {
//           throw ExceptionHandler.fromResponse(response);
//         }
//         return response;
//       } on DioException catch (e) {
//         _logDioError(method: 'POST', url: url, error: e);
//         final mapped = ExceptionHandler.fromDio(e);
//         final canRetry429 = mapped.statusCode == 429 && attempt < maxRetries;
//         if (canRetry429) {
//           attempt++;
//           final waitMs = mapped.retryAfterMs ?? 2000;
//           _debugLog('API 429 → retrying after ${waitMs}ms (attempt $attempt)');
//           await Future<void>.delayed(Duration(milliseconds: waitMs));
//           continue;
//         }
//         throw mapped;
//       } on ApiException catch (e) {
//         _debugLog(
//           'API ApiException [${e.statusCode}] $url → ${e.message}',
//         );
//         final canRetry429 = e.statusCode == 429 && attempt < maxRetries;
//         if (canRetry429) {
//           attempt++;
//           final waitMs = e.retryAfterMs ?? 2000;
//           _debugLog('API 429 → retrying after ${waitMs}ms (attempt $attempt)');
//           await Future<void>.delayed(Duration(milliseconds: waitMs));
//           continue;
//         }
//         rethrow;
//       }
//     }
//   }
//
//   Future<Response> deleteRequestResponse(
//     String url, {
//     String? authToken,
//     bool requireAuth = false,
//   }) async {
//     final options = _authOptions(authToken: authToken, requireAuth: requireAuth);
//     _logRequest(method: 'DELETE', url: url);
//     try {
//       final response = await _dio.delete(url, options: options);
//       _logResponse(method: 'DELETE', url: url, response: response);
//       if (!ExceptionHandler.isSuccessResponse(response)) {
//         throw ExceptionHandler.fromResponse(response);
//       }
//       return response;
//     } on DioException catch (e) {
//       _logDioError(method: 'DELETE', url: url, error: e);
//       throw ExceptionHandler.fromDio(e);
//     }
//   }
//
//   Options? _authOptions({String? authToken, bool requireAuth = false}) {
//     final token = (authToken ?? _authTokenProvider?.call())?.trim();
//     if (token == null || token.isEmpty) {
//       if (requireAuth) {
//         throw const ApiException(
//           'Sign in required.',
//           statusCode: 401,
//         );
//       }
//       return null;
//     }
//     return Options(headers: {'Authorization': 'Bearer $token'});
//   }
//
//   static bool handleResponseStatus(Response response) {
//     return ExceptionHandler.isSuccessResponse(response);
//   }
//
//   void dispose() {
//     _dio.close(force: true);
//   }
//
//   void _logRequest({
//     required String method,
//     required String url,
//     Map<String, dynamic>? body,
//     int attempt = 0,
//   }) {
//     if (!kDebugMode) return;
//     final attemptSuffix = attempt > 0 ? ' (retry #$attempt)' : '';
//     _debugLog('API REQUEST $method $url$attemptSuffix');
//     if (body != null) {
//       _debugLog(
//         'API BODY:\n${ExceptionHandler.prettyJson(_sanitizeBodyForLog(body))}',
//       );
//     }
//   }
//
//   void _logResponse({
//     required String method,
//     required String url,
//     required Response response,
//   }) {
//     if (!kDebugMode) return;
//     _debugLog(
//       'API RESPONSE $method $url → ${response.statusCode}',
//     );
//     _debugLog('API RESPONSE HEADERS: ${response.headers.map}');
//     _debugLog(
//       'API RESPONSE BODY:\n${ExceptionHandler.prettyJson(response.data)}',
//     );
//   }
//
//   void _logDioError({
//     required String method,
//     required String url,
//     required DioException error,
//   }) {
//     if (!kDebugMode) return;
//     final status = error.response?.statusCode;
//     _debugLog(
//       'API ERROR $method $url → status=$status type=${error.type}',
//     );
//     if (error.response != null) {
//       _debugLog('API ERROR HEADERS: ${error.response!.headers.map}');
//       _debugLog(
//         'API ERROR BODY:\n${ExceptionHandler.prettyJson(error.response!.data)}',
//       );
//     } else {
//       _debugLog('API ERROR (no response) message=${error.message}');
//       if (error.error != null) {
//         _debugLog('API ERROR CAUSE: ${error.error}');
//       }
//     }
//   }
//
//   /// Truncates huge base64 fields so debug logs stay readable.
//   Map<String, dynamic> _sanitizeBodyForLog(Map<String, dynamic> body) {
//     final copy = Map<String, dynamic>.from(body);
//     final image = copy['imageBase64'];
//     if (image is String && image.length > 120) {
//       copy['imageBase64'] =
//           '${image.substring(0, 40)}...(${image.length} chars)';
//     }
//     return copy;
//   }
//
//   void _debugLog(String message) {
//     if (!kDebugMode) return;
//     const chunk = 800;
//     for (var i = 0; i < message.length; i += chunk) {
//       final end = (i + chunk < message.length) ? i + chunk : message.length;
//       debugPrint(message.substring(i, end));
//     }
//   }
// }
