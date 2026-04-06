import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String baseUrl = 'http://10.0.2.2:3000/api/v1'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Filament Types
  Future<Response> getFilamentTypes({Map<String, dynamic>? query}) =>
      _dio.get('/filament-types', queryParameters: query);

  Future<Response> getFilamentType(String id) =>
      _dio.get('/filament-types/$id');

  Future<Response> getFilamentTypeByCode(String code) =>
      _dio.get('/filament-types/code/$code');

  Future<Response> createFilamentType(Map<String, dynamic> data) =>
      _dio.post('/filament-types', data: data);

  Future<Response> updateFilamentType(String id, Map<String, dynamic> data) =>
      _dio.put('/filament-types/$id', data: data);

  Future<Response> deleteFilamentType(String id) =>
      _dio.delete('/filament-types/$id');

  Future<Response> batchImportFilamentTypes(List<Map<String, dynamic>> items) =>
      _dio.post('/filament-types/import', data: items);

  // Inventory
  Future<Response> getInventory({String? status, String? brand}) =>
      _dio.get('/inventory', queryParameters: {
        if (status != null) 'status': status,
        if (brand != null) 'brand': brand,
      });

  Future<Response> getInventoryStats() => _dio.get('/inventory/stats');

  Future<Response> getInventoryItem(String id) =>
      _dio.get('/inventory/$id');

  Future<Response> createInventoryItem(Map<String, dynamic> data) =>
      _dio.post('/inventory', data: data);

  Future<Response> updateInventoryItem(String id, Map<String, dynamic> data) =>
      _dio.put('/inventory/$id', data: data);

  Future<Response> updateInventoryStatus(String id, Map<String, dynamic> data) =>
      _dio.patch('/inventory/$id/status', data: data);

  Future<Response> deleteInventoryItem(String id) =>
      _dio.delete('/inventory/$id');

  // Positions
  Future<Response> getPositions() => _dio.get('/positions');

  Future<Response> createPosition(Map<String, dynamic> data) =>
      _dio.post('/positions', data: data);

  Future<Response> updatePosition(String id, Map<String, dynamic> data) =>
      _dio.put('/positions/$id', data: data);

  Future<Response> deletePosition(String id) =>
      _dio.delete('/positions/$id');

  // Sync
  Future<Response> pushSync(Map<String, dynamic> data) =>
      _dio.post('/sync/push', data: data);

  Future<Response> pullSync(String since) =>
      _dio.get('/sync/pull', queryParameters: {'since': since});
}
