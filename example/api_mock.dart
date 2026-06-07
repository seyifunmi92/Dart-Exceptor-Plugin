import 'model.dart';

class MockAPiCall {
  Future<ApiResponse<T>> callApi<T>({required int code, T? data}) async {
    try {
      final res = ApiResponse<T>(code: code, data: data);
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
