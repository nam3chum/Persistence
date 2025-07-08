import 'package:dio/dio.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(request: true, requestBody: true, responseBody: true, responseHeader: false),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          //Gắn token tự động
          //options.headers["Authorization"]  = "Bearer $accessToken;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (DioException e, handler) {
          print(' Error caught: ${_handleError(e)}');
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối quá chậm, thử lại sau';
      case DioExceptionType.sendTimeout:
        return 'Gửi dữ liệu quá chậm';
      case DioExceptionType.receiveTimeout:
        return 'Nhận dữ liệu quá chậm';
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return 'Dữ liệu không hợp lệ';
          case 401:
            return 'Chưa đăng nhập hoặc token hết hạn';
          case 403:
            return 'Không có quyền truy cập';
          case 404:
            return 'Không tìm thấy dữ liệu';
          case 500:
            return 'Lỗi server, thử lại sau';
          default:
            return 'Lỗi không xác định: ${e.response?.statusCode}';
        }
      case DioExceptionType.cancel:
        return 'Request đã bị hủy';
      case DioExceptionType.connectionError:
        return 'Không có kết nối internet';
      default:
        return 'Lỗi không xác định: ${e.message}';
    }
  }
}
