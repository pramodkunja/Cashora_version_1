import '../../core/services/network_service.dart';

/// Repository for the /categories API (admin-only mutations).
///
/// Mirrors [DepartmentRepository]. The requestor side reads category *names*
/// from `/requestor/categories`; admins manage the full records here.
class CategoryRepository {
  final NetworkService _networkService;

  CategoryRepository(this._networkService);

  /// POST /categories
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? code,
  }) async {
    final payload = <String, dynamic>{'name': name};
    if (code != null && code.isNotEmpty) payload['code'] = code;

    final response = await _networkService.post('/categories', data: payload);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /categories
  ///
  /// Resilient to both response shapes: a list of objects (preferred) or a
  /// bare list of category-name strings (as `/requestor/categories` returns).
  Future<List<Map<String, dynamic>>> listCategories({
    bool includeInactive = false,
  }) async {
    final response = await _networkService.get(
      '/categories',
      queryParameters: includeInactive ? {'include_inactive': true} : null,
    );
    final data = response.data;
    if (data is List) {
      return data.map<Map<String, dynamic>>((item) {
        if (item is Map) return Map<String, dynamic>.from(item);
        return {'name': item.toString(), 'is_active': true};
      }).toList();
    }
    return [];
  }

  /// POST /categories/seed-defaults
  Future<Map<String, dynamic>> seedDefaults() async {
    final response = await _networkService.post('/categories/seed-defaults');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /categories/{id}
  Future<Map<String, dynamic>> getCategory(int id) async {
    final response = await _networkService.get('/categories/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /categories/{id}
  Future<Map<String, dynamic>> updateCategory(
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
        await _networkService.patch('/categories/$id', data: payload);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// DELETE /categories/{id} — soft delete.
  Future<void> deleteCategory(int id) async {
    await _networkService.delete('/categories/$id');
  }
}
