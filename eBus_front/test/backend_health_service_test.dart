import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bus/services/backend_health_service.dart';

class ProbeAdapter implements HttpClientAdapter {
  ProbeAdapter(this.statuses, {this.hang = false});
  final List<int> statuses;
  final bool hang;
  int calls = 0;
  int active = 0;
  int maxActive = 0;
  int cancelled = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    active++;
    if (active > maxActive) maxActive = active;
    try {
      if (hang) {
        await cancelFuture;
        cancelled++;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
        );
      }
      return ResponseBody.fromString('', statuses.removeAt(0));
    } finally {
      active--;
    }
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  setUp(() => dio = Dio(BaseOptions(baseUrl: 'https://example.test')));
  tearDown(() => dio.close(force: true));

  test('only 200 succeeds, probes remain sequential', () async {
    final adapter = ProbeAdapter([403, 503, 204, 200]);
    dio.httpClientAdapter = adapter;
    await BackendHealthService(
      dio,
      retryDelay: const Duration(milliseconds: 1),
    ).waitUntilReady(CancelToken());
    expect(adapter.calls, 4);
    expect(adapter.maxActive, 1);
  });

  test('global deadline cancels an active HTTP request', () async {
    final adapter = ProbeAdapter([], hang: true);
    dio.httpClientAdapter = adapter;
    await expectLater(
      BackendHealthService(
        dio,
        totalTimeout: const Duration(milliseconds: 30),
      ).waitUntilReady(CancelToken()),
      throwsA(isA<TimeoutException>()),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(adapter.calls, 1);
    expect(adapter.cancelled, 1);
    expect(adapter.active, 0);
  });

  test('caller cancellation stops retries during the pause', () async {
    final adapter = ProbeAdapter([503]);
    dio.httpClientAdapter = adapter;
    final token = CancelToken();
    final result = BackendHealthService(dio).waitUntilReady(token);
    final expectation = expectLater(result, throwsA(isA<TimeoutException>()));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    token.cancel('disposed');
    await expectation;
    expect(adapter.calls, 1);
  });

  test('request timeout cancels transport before the next probe', () async {
    final adapter = ProbeAdapter([], hang: true);
    dio.httpClientAdapter = adapter;
    await expectLater(
      BackendHealthService(
        dio,
        requestTimeout: const Duration(milliseconds: 10),
        retryDelay: const Duration(milliseconds: 5),
        totalTimeout: const Duration(milliseconds: 55),
      ).waitUntilReady(CancelToken()),
      throwsA(isA<TimeoutException>()),
    );
    expect(adapter.calls, greaterThan(1));
    expect(adapter.maxActive, 1);
  });
}
