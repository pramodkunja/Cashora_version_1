import '../../core/services/network_service.dart';

/// Repository for the /departments API (admin-only mutations).
class DepartmentRepository {
  final NetworkService _networkService;

  DepartmentRepository(this._networkService);

  /// POST /departments
  Future<Map<String, dynamic>> createDepartment({
    required String name,
    String? code,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (code != null && code.isNotEmpty) payload['code'] = code;

    final response = await _networkService.post('/departments', data: payload);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /departments
  Future<List<Map<String, dynamic>>> listDepartments({
    bool includeInactive = false,
  }) async {
    final response = await _networkService.get(
      '/departments',
      queryParameters: includeInactive ? {'include_inactive': true} : null,
    );
    if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    return [];
  }

  /// POST /departments/seed-defaults
  Future<Map<String, dynamic>> seedDefaults() async {
    final response = await _networkService.post('/departments/seed-defaults');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /departments/{id}
  Future<Map<String, dynamic>> getDepartment(int id) async {
    final response = await _networkService.get('/departments/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /departments/{id}
  Future<Map<String, dynamic>> updateDepartment(
    int id, {
    String? name,
    String? code,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (code != null) payload['code'] = code;
    if (isActive != null) payload['is_active'] = isActive;

    final response =
        await _networkService.patch('/departments/$id', data: payload);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// DELETE /departments/{id} — soft delete.
  Future<void> deleteDepartment(int id) async {
    await _networkService.delete('/departments/$id');
  }

  /// GET /departments/{id}/users
  Future<Map<String, dynamic>> listUsers(int id) async {
    final response = await _networkService.get('/departments/$id/users');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
