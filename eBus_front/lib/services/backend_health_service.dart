import 'dart:async';

import 'package:dio/dio.dart';
import '../constants/constants.dart';

/// One sequential startup probe. The caller owns cancellation and the client.
class BackendHealthService {
  BackendHealthService(
    this._dio, {
    this.retryDelay = const Duration(seconds: 5),
    this.requestTimeout = const Duration(seconds: 10),
    this.totalTimeout = const Duration(seconds: 120),
  });

  final Dio _dio;
  final Duration retryDelay;
  final Duration requestTimeout;
  final Duration totalTimeout;

  Future<void> waitUntilReady(CancelToken cancellation) async {
    final deadline = Timer(totalTimeout, () {
      cancellation.cancel('Backend startup deadline exceeded');
    });
    try {
      while (!cancellation.isCancelled) {
        final request = CancelToken();
        // Cancels the actual HTTP request, including on Web and on disposal.
        cancellation.whenCancel.then((_) {
          request.cancel();
        });
        final requestDeadline = Timer(requestTimeout, () => request.cancel());
        try {
          final response = await _dio.get<dynamic>(
            AppConstants.healthPath,
            cancelToken: request,
            options: Options(
              extra: const {'publicHealthCheck': true},
              responseType: ResponseType.plain,
              followRedirects: false,
              validateStatus: (_) => true,
              receiveTimeout: requestTimeout,
              sendTimeout: requestTimeout,
            ),
          );
          if (!cancellation.isCancelled && response.statusCode == 200) return;
        } on DioException {
          // Includes offline, CORS, timeout, and cancellation errors.
        } finally {
          requestDeadline.cancel();
        }
        if (cancellation.isCancelled) break;
        await Future.any([
          Future<void>.delayed(retryDelay),
          cancellation.whenCancel.then<void>((_) {}),
        ]);
      }
      throw TimeoutException('Backend unavailable', totalTimeout);
    } finally {
      deadline.cancel();
    }
  }
}
