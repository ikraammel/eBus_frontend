import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../utils/shared_prefs_helper.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPrefsHelper.getToken();
          print("TOKEN FROM PREFS: $token");

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print("REQUEST HEADERS: ${options.headers}");

          return handler.next(options);
        },
        onError: (error, handler) {
          // gérer 401 globalement si besoin

          return handler.next(error);
        },
      ),
    );
}
