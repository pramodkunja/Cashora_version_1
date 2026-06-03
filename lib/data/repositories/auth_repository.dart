import 'package:flutter/foundation.dart';
import '../../core/services/network_service.dart';
import '../models/user_model.dart';
import '../models/user_update_request.dart';

class AuthRepository {
  final NetworkService _networkService;

  AuthRepository(this._networkService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _networkService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      User user;
      String? token;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('user')) {
          user = User.fromJson(data['user']);
        } else {
          user = User.fromJson(data);
        }

        token = data['access_token'] as String?;
        if (token == null && kDebugMode) {
          token = (data['token'] ?? data['auth_token']) as String?;
        }
      } else {
        throw Exception('Invalid response format');
      }

      return {'user': user, 'token': token};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _networkService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    try {
      await _networkService.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await _networkService.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otp':
              otp, // Sending OTP again or a token if the previous step returned one. Assuming OTP for now.
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _networkService.post(
        '/users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST /auth/logout
  ///
  /// TODO(backend): endpoint may 404 until the server-side logout route
  /// ships. Caller (AuthService.logout) must always clear local state
  /// regardless of what this returns or throws.
  Future<void> logout() async {
    await _networkService.post('/auth/logout');
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _networkService.get('/auth/users');
      final data = response.data;

      if (data is List) {
        return data.map((user) => user as Map<String, dynamic>).toList();
      } else if (data is Map<String, dynamic> && data.containsKey('users')) {
        final users = data['users'];
        if (users is List) {
          return users.map((user) => user as Map<String, dynamic>).toList();
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    int? departmentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phone,
        'role': role,
      };
      if (departmentId != null) data['department_id'] = departmentId;

      final response = await _networkService.post(
        '/auth/add-staff',
        data: data,
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH /users/update/{userId}
  ///
  /// Backend does **not** support email updates through this endpoint, so
  /// `email` is intentionally absent from [UserUpdateRequest]. Only the
  /// fields the caller actually wants to change are sent — non-null fields
  /// in the request are included; everything else is omitted to avoid
  /// overwriting unrelated columns with null.
  Future<Map<String, dynamic>> patchUser({
    required String userId,
    required UserUpdateRequest request,
  }) async {
    final body = request.toJson();
    if (body.isEmpty) {
      throw ArgumentError('UserUpdateRequest is empty — nothing to update.');
    }
    final response = await _networkService.patch(
      '/users/update/$userId',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    required bool isActive,
    int? departmentId,
  }) {
    return patchUser(
      userId: userId,
      request: UserUpdateRequest(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
        role: role,
        isActive: isActive,
        departmentId: departmentId,
      ),
    );
  }

  Future<Map<String, dynamic>> deactivateUser({required String userId}) {
    return patchUser(
      userId: userId,
      request: const UserUpdateRequest(isActive: false),
    );
  }

  Future<Map<String, dynamic>> activateUser({required String userId}) {
    return patchUser(
      userId: userId,
      request: const UserUpdateRequest(isActive: true),
    );
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _networkService.get('/users/me');

      final data = response.data;
      if (data != null) {
         if (data is Map<String, dynamic>) {
            // Handle {user: {...}} or direct {...}
            if (data.containsKey('user')) {
              return User.fromJson(data['user']);
            }
            return User.fromJson(data);
         }
      }
      return null;
    } catch (e) {
      // If 401, returns null, which AuthService handles by logging out
      return null;
    }
  }
}
